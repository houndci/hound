module HamlLint
  # Checks that classes are listed before IDs in tags.
  class Linter::ClassesBeforeIds < Linter
    include LinterRegistry

    # Map of prefixes to the type of tag component
    TYPES_BY_PREFIX = {
      '.' => :class,
      '#' => :id,
    }

    def visit_tag(node)
      # Convert ".class#id" into [.class, #id] (preserving order)
      components = node.static_attributes_source.scan(/[.#][^.#]+/)

      (1...components.count).each do |index|
        next unless components[index].start_with?('.') &&
                    components[index - 1].start_with?('#')

        record_lint(node, 'Classes should be listed before IDs '\
                          "(#{components[index]} should precede #{components[index - 1]})")
        break
      end
    end
  end
end
