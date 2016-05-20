# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for multi-line ternary op expressions.
      class MultilineTernaryOperator < Cop
        MSG = 'Avoid multi-line ?: (the ternary operator);' \
              ' use `if`/`unless` instead.'

        def on_if(node)
          loc = node.loc

          # discard non-ternary ops
          return unless loc.respond_to?(:question)

          add_offense(node, :expression) if loc.line != loc.colon.line
        end
      end
    end
  end
end
