# encoding: utf-8

module RuboCop
  module Cop
    class VariableForce
      # This class represents each reference of a variable.
      class Reference
        include Locatable

        VARIABLE_REFERENCE_TYPES = (
          [VARIABLE_REFERENCE_TYPE] +
          OPERATOR_ASSIGNMENT_TYPES +
          [ZERO_ARITY_SUPER_TYPE]
        ).freeze

        attr_reader :node, :scope

        def initialize(node, scope)
          unless VARIABLE_REFERENCE_TYPES.include?(node.type)
            fail ArgumentError,
                 "Node type must be any of #{VARIABLE_REFERENCE_TYPES}, " \
                 "passed #{node.type}"
          end

          @node = node
          @scope = scope
        end

        # There's an implicit variable reference by the zero-arity `super`:
        #
        #     def some_method(foo)
        #       super
        #     end
        #
        # In this case, the variable `foo` is not explicitly referenced,
        # but it can be considered used implicitly by the `super`.
        def explicit?
          @node.type != ZERO_ARITY_SUPER_TYPE
        end
      end
    end
  end
end
