module HamlLint
  # Checks the character used for indentation.
  class Linter::Indentation < Linter
    include LinterRegistry

    # Allowed leading indentation for each character type.
    INDENT_REGEX = {
      space: /^[ ]*(?!\t)/,
      tab: /^\t*(?![ ])/,
    }

    def visit_root(_node)
      regex = INDENT_REGEX[config['character'].to_sym]
      dummy_node = Struct.new(:line)

      document.source_lines.each_with_index do |line, index|
        next if line =~ regex

        record_lint dummy_node.new(index + 1), 'Line contains tabs in indentation'
      end
    end
  end
end
