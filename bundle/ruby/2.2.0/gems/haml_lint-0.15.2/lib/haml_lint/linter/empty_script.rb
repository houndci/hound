module HamlLint
  # Checks for empty scripts.
  class Linter::EmptyScript < Linter
    include LinterRegistry

    def visit_silent_script(node)
      return unless node.script =~ /\A\s*\Z/

      record_lint(node, 'Empty script should be removed')
    end
  end
end
