module HamlLint
  # Checks for unnecessary outputting of strings in Ruby script tags.
  #
  # For example, the following two code snippets are equivalent, but the latter
  # is more concise (and thus preferred):
  #
  #   %tag= "Some #{expression}"
  #   %tag Some #{expression}
  class Linter::UnnecessaryStringOutput < Linter
    include LinterRegistry

    MESSAGE = '`= "..."` should be rewritten as `...`'

    def visit_tag(node)
      if tag_has_inline_script?(node) && inline_content_is_string?(node)
        record_lint(node, MESSAGE)
      end
    end

    def visit_script(node)
      # Some script nodes created by the HAML parser aren't actually script
      # nodes declared via the `=` marker. Check for it.
      return if node.source_code !~ /\s*=/

      if outputs_string_literal?(node)
        record_lint(node, MESSAGE)
      end
    end

    private

    def outputs_string_literal?(script_node)
      return unless tree = parse_ruby(script_node.script)
      [:str, :dstr].include?(tree.type) &&
        !starts_with_reserved_character?(tree.children.first)
    rescue ::Parser::SyntaxError # rubocop:disable Lint/HandleExceptions
      # Gracefully ignore syntax errors, as that's managed by a different linter
    end

    # Returns whether a string starts with a character that would otherwise be
    # given special treatment, thus making enclosing it in a string necessary.
    def starts_with_reserved_character?(stringish)
      string = stringish.respond_to?(:children) ? stringish.children.first : stringish
      string =~ %r{\A\s*[/#-=%~]}
    end
  end
end
