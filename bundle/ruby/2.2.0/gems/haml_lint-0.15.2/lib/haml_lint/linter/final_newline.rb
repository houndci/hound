module HamlLint
  # Checks for final newlines at the end of a file.
  class Linter::FinalNewline < Linter
    include LinterRegistry

    def visit_root(_node)
      return if document.source.empty?

      dummy_node = Struct.new(:line).new(document.source_lines.count)
      ends_with_newline = document.source.end_with?("\n")

      if config['present']
        record_lint(dummy_node,
                    'Files should end with a trailing newline') unless ends_with_newline
      else
        record_lint(dummy_node,
                    'Files should not end with a trailing newline') if ends_with_newline
      end
    end
  end
end
