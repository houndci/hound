# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for empty `ensure` blocks
      class EmptyEnsure < Cop
        MSG = 'Empty `ensure` block detected.'

        def on_ensure(node)
          _body, ensure_body = *node

          add_offense(node, :keyword) unless ensure_body
        end
      end
    end
  end
end
