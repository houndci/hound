module HamlLint
  # Checks for multiple lines of code comments that can be condensed.
  class Linter::ConsecutiveComments < Linter
    include LinterRegistry

    COMMENT_DETECTOR = ->(child) { child.type == :haml_comment }

    def visit_root(node)
      HamlLint::Utils.for_consecutive_items(
        node.children,
        COMMENT_DETECTOR,
      ) do |group|
        record_lint(group.first,
                    "#{group.count} consecutive comments can be merged into one")
      end
    end
  end
end
