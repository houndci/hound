module HamlLint
  # Checks for class attributes defined in tag attribute hash with static
  # values.
  #
  # For example, it will prefer this:
  #
  #   %tag.class-name
  #
  # ...over:
  #
  #   %tag{ class: 'class-name' }
  class Linter::ClassAttributeWithStaticValue < Linter
    include LinterRegistry

    STATIC_TYPES = [:str, :sym]
    STATIC_CLASSES = [String, Symbol]

    def visit_tag(node)
      return unless contains_class_attribute?(node.dynamic_attributes_sources)

      record_lint(node, 'Avoid defining `class` in attributes hash ' \
                        'for static class names')
    end

    private

    def contains_class_attribute?(attributes_sources)
      attributes_sources.each do |code|
        begin
          ast_root = parse_ruby(code.start_with?('{') ? code : "{#{code}}")
        rescue ::Parser::SyntaxError
          next # RuboCop linter will report syntax errors
        end

        ast_root.children.each do |pair|
          return true if static_class_attribute_value?(pair)
        end
      end

      false
    end

    def static_class_attribute_value?(pair)
      key, value = pair.children

      STATIC_TYPES.include?(key.type) &&
        key.children.first.to_sym == :class &&
        STATIC_CLASSES.include?(value.children.first.class)
    end
  end
end
