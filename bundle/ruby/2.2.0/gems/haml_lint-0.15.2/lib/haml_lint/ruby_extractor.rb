module HamlLint
  # Utility class for extracting Ruby script from a HAML file that can then be
  # linted with a Ruby linter (i.e. is "legal" Ruby). The goal is to turn this:
  #
  #     - if signed_in?(viewer)
  #       %span Stuff
  #       = link_to 'Sign Out', sign_out_path
  #     - else
  #       .some-class{ class: my_method }= my_method
  #       = link_to 'Sign In', sign_in_path
  #
  # into this:
  #
  #     if signed_in?(viewer)
  #       link_to 'Sign Out', sign_out_path
  #     else
  #       { class: my_method }
  #       my_method
  #       link_to 'Sign In', sign_in_path
  #     end
  #
  # The translation won't be perfect, and won't make any real sense, but the
  # relationship between variable declarations/uses and the flow control graph
  # will remain intact.
  class RubyExtractor
    include HamlVisitor

    # Stores the extracted source and a map of lines of generated source to the
    # original source that created them.
    #
    # @attr_reader source [String] generated source code
    # @attr_reader source_map [Hash] map of line numbers from generated source
    #   to original source line number
    RubySource = Struct.new(:source, :source_map)

    # Extracts Ruby code from Sexp representing a Slim document.
    #
    # @param document [HamlLint::Document]
    # @return [HamlLint::RubyExtractor::RubySource]
    def extract(document)
      visit(document.tree)
      RubySource.new(@source_lines.join("\n"), @source_map)
    end

    def visit_root(_node)
      @source_lines = []
      @source_map = {}
      @line_count = 0
      @indent_level = 0

      yield # Collect lines of code from children
    end

    def visit_plain(node)
      # Don't output the text, as we don't want to have to deal with any RuboCop
      # cops regarding StringQuotes or AsciiComments, and it's not important to
      # overall document anyway.
      add_line('puts', node)
    end

    def visit_tag(node)
      additional_attributes = node.dynamic_attributes_sources

      # Include dummy references to code executed in attributes list
      # (this forces a "use" of a variable to prevent "assigned but unused
      # variable" lints)
      additional_attributes.each do |attributes_code|
        # Normalize by removing excess whitespace to avoid format lints
        attributes_code = attributes_code.gsub(/\s*\n\s*/, ' ').strip

        # Attributes can either be a method call or a literal hash, so wrap it
        # in a method call itself in order to avoid having to differentiate the
        # two.
        add_line("{}.merge(#{attributes_code.strip})", node)
      end

      check_tag_static_hash_source(node)

      # We add a dummy puts statement to represent the tag name being output.
      # This prevents some erroneous RuboCop warnings.
      add_line("puts # #{node.tag_name}", node)

      code = node.script.strip
      add_line(code, node) unless code.empty?
    end

    def after_visit_tag(node)
      # We add a dummy puts statement for closing tag.
      add_line("puts # #{node.tag_name}/", node)
    end

    def visit_script(node)
      code = node.text
      add_line(code.strip, node)

      start_block = anonymous_block?(code) || start_block_keyword?(code)

      if start_block
        @indent_level += 1
      end

      yield # Continue extracting code from children

      if start_block
        @indent_level -= 1
        add_line('end', node)
      end
    end

    def visit_silent_script(node, &block)
      visit_script(node, &block)
    end

    def visit_filter(node)
      if node.filter_type == 'ruby'
        node.text.split("\n").each_with_index do |line, index|
          add_line(line, node.line + index + 1)
        end
      else
        add_line('puts', node)
        HamlLint::Utils.extract_interpolated_values(node.text) do |interpolated_code, line|
          add_line(interpolated_code, node.line + line)
        end
      end
    end

    private

    def check_tag_static_hash_source(node)
      # Haml::Parser converts hashrocket-style hash attributes of strings and symbols
      # to static attributes, and excludes them from the dynamic attribute sources:
      # https://github.com/haml/haml/blob/08f97ec4dc8f59fe3d7f6ab8f8807f86f2a15b68/lib/haml/parser.rb#L400-L404
      # https://github.com/haml/haml/blob/08f97ec4dc8f59fe3d7f6ab8f8807f86f2a15b68/lib/haml/parser.rb#L540-L554
      # Here, we add the hash source back in so it can be inspected by rubocop.
      if node.hash_attributes? && node.dynamic_attributes_sources.empty?
        normalized_attr_source = node.dynamic_attributes_source[:hash].gsub(/\s*\n\s*/, ' ')

        add_line(normalized_attr_source, node)
      end
    end

    def add_line(code, node_or_line)
      return if code.empty?

      indent_level = @indent_level

      if node_or_line.respond_to?(:line)
        # Since mid-block keywords are children of the corresponding start block
        # keyword, we need to reduce their indentation level by 1. However, we
        # don't do this unless this is an actual tag node (a raw line number
        # means this came from a `:ruby` filter).
        indent_level -= 1 if mid_block_keyword?(code)
      end

      indent = (' ' * 2 * indent_level)

      @source_lines << indent + code

      original_line =
        node_or_line.respond_to?(:line) ? node_or_line.line : node_or_line

      # For interpolated code in filters that spans multiple lines, the
      # resulting code will span multiple lines, so we need to create a
      # mapping for each line.
      (code.count("\n") + 1).times do
        @line_count += 1
        @source_map[@line_count] = original_line
      end
    end

    def anonymous_block?(text)
      text =~ /\bdo\s*(\|\s*[^\|]*\s*\|)?(\s*#.*)?\z/
    end

    START_BLOCK_KEYWORDS = %w[if unless case begin for until while]
    def start_block_keyword?(text)
      START_BLOCK_KEYWORDS.include?(block_keyword(text))
    end

    MID_BLOCK_KEYWORDS = %w[else elsif when rescue ensure]
    def mid_block_keyword?(text)
      MID_BLOCK_KEYWORDS.include?(block_keyword(text))
    end

    def block_keyword(text)
      # Need to handle 'for'/'while' since regex stolen from HAML parser doesn't
      if keyword = text[/\A\s*([^\s]+)\s+/, 1]
        return keyword if %w[for until while].include?(keyword)
      end

      return unless keyword = text.scan(Haml::Parser::BLOCK_KEYWORD_REGEX)[0]
      keyword[0] || keyword[1]
    end
  end
end
