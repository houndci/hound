module HamlLint
  # Checks for uses of the object reference syntax for assigning the class and
  # ID attributes for an element (e.g. `%div[@user]`).
  class Linter::ObjectReferenceAttributes < Linter
    include LinterRegistry

    def visit_tag(node)
      return unless node.object_reference?

      record_lint(node, 'Avoid using object reference syntax to assign class/id ' \
                     'attributes for tags')
    end
  end
end
