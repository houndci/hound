# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of the case equality operator(===).
      class CaseEquality < Cop
        MSG = 'Avoid the use of the case equality operator `===`.'

        def on_send(node)
          _receiver, method_name, *_args = *node

          add_offense(node, :selector) if method_name == :===
        end
      end
    end
  end
end
