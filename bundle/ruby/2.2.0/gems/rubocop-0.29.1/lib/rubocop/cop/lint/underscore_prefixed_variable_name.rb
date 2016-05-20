# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for underscore-prefixed variables that are actually
      # used.
      class UnderscorePrefixedVariableName < Cop
        MSG = 'Do not use prefix `_` for a variable that is used.'

        def join_force?(force_class)
          force_class == VariableForce
        end

        def after_leaving_scope(scope, _variable_table)
          scope.variables.each_value do |variable|
            check_variable(variable)
          end
        end

        def check_variable(variable)
          return unless variable.should_be_unused?
          return if variable.references.empty?
          return if variable.references.none?(&:explicit?)

          node = variable.declaration_node

          location = if node.type == :match_with_lvasgn
                       node.children.first.loc.expression
                     else
                       node.loc.name
                     end

          add_offense(nil, location)
        end
      end
    end
  end
end
