module HamlLint
  # Checks for uses of the multiline pipe character.
  class Linter::MultilinePipe < Linter
    include LinterRegistry

    MESSAGE = "Don't use the `|` character to split up lines. " \
              'Wrap on commas or extract code into helper.'

    def visit_tag(node)
      check(node)
    end

    def visit_script(node)
      check(node)
    end

    def visit_silent_script(node)
      check(node)
    end

    def visit_plain(node)
      line = line_text_for_node(node)

      # Plain text nodes are allowed to consist of a single pipe
      return if line.strip == '|'

      record_lint(node, MESSAGE) if line.match(MULTILINE_PIPE_REGEX)
    end

    private

    MULTILINE_PIPE_REGEX = /\s+\|\s*$/

    def line_text_for_node(node)
      document.source_lines[node.line - 1]
    end

    def check(node)
      line = line_text_for_node(node)
      record_lint(node, MESSAGE) if line.match(MULTILINE_PIPE_REGEX)
    end
  end
end
