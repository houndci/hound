module HamlLint
  # Checks for tag names with uppercase letters.
  class Linter::TagName < Linter
    include LinterRegistry

    def visit_tag(node)
      tag = node.tag_name
      return unless tag.match(/[A-Z]/)

      record_lint(node, "`#{tag}` should be written in lowercase as `#{tag.downcase}`")
    end
  end
end
