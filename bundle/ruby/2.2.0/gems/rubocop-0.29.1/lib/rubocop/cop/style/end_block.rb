# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for END blocks.
      class EndBlock < Cop
        MSG = 'Avoid the use of `END` blocks. Use `Kernel#at_exit` instead.'

        def on_postexe(node)
          add_offense(node, :keyword)
        end
      end
    end
  end
end
