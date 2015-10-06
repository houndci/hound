module HamlLint
  # Checks for comments that don't have a leading space.
  class Linter::LeadingCommentSpace < Linter
    include LinterRegistry

    def visit_haml_comment(node)
      # Skip if the node spans multiple lines starting on the second line,
      # or starts with a space
      return if node.text.match(/\A(\s*|\s+\S.*)$/)

      record_lint(node, 'Comment should have a space after the `#`')
    end
  end
end
