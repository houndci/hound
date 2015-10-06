module HamlLint
  # Checks for the setting of attributes via HTML shorthand syntax on elements
  # (e.g. `%tag(lang=en)`).
  class Linter::HtmlAttributes < Linter
    include LinterRegistry

    def visit_tag(node)
      return unless node.html_attributes?

      record_lint(node, "Prefer the hash attributes syntax (%tag{ lang: 'en' }) " \
                        'over HTML attributes syntax (%tag(lang=en))')
    end
  end
end
