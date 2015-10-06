module HamlLint
  # Base implementation for all lint checks.
  #
  # @abstract
  class Linter
    include HamlVisitor

    # List of lints reported by this linter.
    #
    # @todo Remove once spec/support/shared_linter_context returns an array of
    #   lints for the subject instead of the linter itself.
    attr_reader :lints

    # Initializes a linter with the specified configuration.
    #
    # @param config [Hash] configuration for this linter
    def initialize(config)
      @config = config
      @lints = []
    end

    # Runs the linter against the given Haml document.
    #
    # @param document [HamlLint::Document]
    def run(document)
      @document = document
      @lints = []
      visit(document.tree)
      @lints
    end

    # Returns the simple name for this linter.
    #
    # @return [String]
    def name
      self.class.name.split('::').last
    end

    private

    attr_reader :config, :document

    # Record a lint for reporting back to the user.
    #
    # @param node [#line] node to extract the line number from
    # @param message [String] error/warning to display to the user
    def record_lint(node, message)
      @lints << HamlLint::Lint.new(self, @document.file, node.line, message,
                                   config.fetch('severity', :warning).to_sym)
    end

    # Parse Ruby code into an abstract syntax tree.
    #
    # @return [AST::Node]
    def parse_ruby(source)
      @ruby_parser ||= HamlLint::RubyParser.new
      @ruby_parser.parse(source)
    end

    # Remove the surrounding double quotes from a string, ignoring any
    # leading/trailing whitespace.
    #
    # @param string [String]
    # @return [String] stripped with leading/trailing double quotes removed.
    def strip_surrounding_quotes(string)
      string[/\A\s*"(.*)"\s*\z/, 1]
    end

    # Returns whether a string contains any interpolation.
    #
    # @param string [String]
    # @return [true,false]
    def contains_interpolation?(string)
      return false unless string
      Haml::Util.contains_interpolation?(string)
    end

    # Returns whether this tag node has inline script, e.g. is of the form
    # %tag= ...
    #
    # @param tag_node [HamlLint::Tree::TagNode]
    # @return [true,false]
    def tag_has_inline_script?(tag_node)
      tag_with_inline_content = tag_with_inline_text(tag_node)
      return false unless inline_content = inline_node_content(tag_node)
      return false unless index = tag_with_inline_content.rindex(inline_content)

      index -= 1
      index -= 1 while [' ', '"', "'"].include?(tag_with_inline_content[index])

      tag_with_inline_content[index] == '='
    end

    # Returns whether the inline content for a node is a string.
    #
    # For example, the following node has a literal string:
    #
    #   %tag= "A literal #{string}"
    #
    # whereas this one does not:
    #
    #   %tag A literal #{string}
    #
    # @param node [HamlLint::Tree::Node]
    # @return [true,false]
    def inline_content_is_string?(node)
      tag_with_inline_content = tag_with_inline_text(node)
      inline_content = inline_node_content(node)

      index = tag_with_inline_content.rindex(inline_content) - 1

      %w[' "].include?(tag_with_inline_content[index])
    end

    # Get the inline content for this node.
    #
    # Inline content is the content that appears inline right after the
    # tag/script. For example, in the code below...
    #
    #   %tag Some inline content
    #
    # ..."Some inline content" would be the inline content.
    #
    # @param node [HamlLint::Tree::Node]
    # @return [String]
    def inline_node_content(node)
      inline_content = node.script

      if contains_interpolation?(inline_content)
        strip_surrounding_quotes(inline_content)
      else
        inline_content
      end
    end

    # Gets the next node following this node, ascending up the ancestor chain
    # recursively if this node has no siblings.
    #
    # @param node [HamlLint::Tree::Node]
    # @return [HamlLint::Tree::Node,nil]
    def next_node(node)
      return unless node
      siblings = node.parent ? node.parent.children : [node]

      next_sibling = siblings[siblings.index(node) + 1] if siblings.count > 1
      return next_sibling if next_sibling

      next_node(node.parent)
    end

    # Returns the line of the "following node" (child of this node or sibling or
    # the last line in the file).
    #
    # @param node [HamlLint::Tree::Node]
    def following_node_line(node)
      [
        [node.children.first, next_node(node)].compact.map(&:line),
        @document.source_lines.count + 1,
      ].flatten.min
    end

    # Extracts all text for a tag node and normalizes it, including additional
    # lines following commas or multiline bar indicators ('|')
    #
    # @param tag_node [HamlLine::Tree::TagNode]
    # @return [String] source code of original parse node
    def tag_with_inline_text(tag_node)
      # Normalize each of the lines to ignore the multiline bar (|) and
      # excess whitespace
      @document.source_lines[(tag_node.line - 1)...(following_node_line(tag_node) - 1)]
        .map do |line|
        line.strip.gsub(/\|\z/, '').rstrip
      end.join(' ')
    end
  end
end
