module HamlLint
  # Represents a parsed Haml document and its associated metadata.
  class Document
    # File name given to source code parsed from just a string.
    STRING_SOURCE = '(string)'

    # @return [HamlLint::Configuration] Configuration used to parse template
    attr_reader :config

    # @return [String] Haml template file path
    attr_reader :file

    # @return [HamlLint::Tree::Node] Root of the parse tree
    attr_reader :tree

    # @return [String] original source code
    attr_reader :source

    # @return [Array<String>] original source code as an array of lines
    attr_reader :source_lines

    # Parses the specified Haml code into a {Document}.
    #
    # @param source [String] Haml code to parse
    # @param options [Hash]
    # @option options :file [String] file name of document that was parsed
    # @raise [Haml::Parser::Error] if there was a problem parsing the document
    def initialize(source, options)
      @config = options[:config]
      @file = options.fetch(:file, STRING_SOURCE)

      process_source(source)
    end

    private

    # @param source [String] Haml code to parse
    # @raise [HamlLint::Exceptions::ParseError] if there was a problem parsing
    def process_source(source)
      @source = process_encoding(source)
      @source = strip_frontmatter(source)
      @source_lines = @source.split("\n")

      @tree = process_tree(Haml::Parser.new(@source, Haml::Options.new).parse)
    rescue Haml::Error => ex
      error = HamlLint::Exceptions::ParseError.new(ex.message, ex.line)
      raise error
    end

    # Processes the {Haml::Parser::ParseNode} tree and returns a tree composed
    # of friendlier {HamlLint::Tree::Node}s.
    #
    # @param original_tree [Haml::Parser::ParseNode]
    # @return [Haml::Tree::Node]
    def process_tree(original_tree)
      # Remove the trailing empty HAML comment that the parser creates to signal
      # the end of the HAML document
      if Gem::Requirement.new('~> 4.0.0').satisfied_by?(Gem.loaded_specs['haml'].version)
        original_tree.children.pop
      end

      @node_transformer = HamlLint::NodeTransformer.new(self)
      convert_tree(original_tree)
    end

    # Converts a HAML parse tree to a tree of {HamlLint::Tree::Node} objects.
    #
    # This provides a cleaner interface with which the linters can interact with
    # the parse tree.
    #
    # @param haml_node [Haml::Parser::ParseNode]
    # @param parent [Haml::Tree::Node]
    # @return [Haml::Tree::Node]
    def convert_tree(haml_node, parent = nil)
      new_node = @node_transformer.transform(haml_node)
      new_node.parent = parent

      new_node.children = haml_node.children.map do |child|
        convert_tree(child, new_node)
      end

      new_node
    end

    # Ensures source code is interpreted as UTF-8.
    #
    # This is necessary as sometimes Ruby guesses the encoding of a file
    # incorrectly, for example if the LC_ALL environment variable is set to "C".
    # @see http://unix.stackexchange.com/a/87763
    #
    # @param source [String]
    # @return [String] source encoded with UTF-8 encoding
    def process_encoding(source)
      source.force_encoding(Encoding::UTF_8)
    end

    # Removes YAML frontmatter
    def strip_frontmatter(source)
      if config['skip_frontmatter'] &&
        source =~ /
          # From the start of the string
          \A
          # First-capture match --- followed by optional whitespace up
          # to a newline then 0 or more chars followed by an optional newline.
          # This matches the --- and the contents of the frontmatter
          (---\s*\n.*?\n?)
          # From the start of the line
          ^
          # Second capture match --- or ... followed by optional whitespace
          # and newline. This matches the closing --- for the frontmatter.
          (---|\.\.\.)\s*$\n?/mx
        source = $POSTMATCH
      end

      source
    end
  end
end
