# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for uses of *begin...end while/until something*.
      class Loop < Cop
        MSG = 'Use `Kernel#loop` with `break` rather than ' \
              '`begin/end/until`(or `while`).'

        def on_while_post(node)
          register_offense(node)
        end

        def on_until_post(node)
          register_offense(node)
        end

        private

        def register_offense(node)
          add_offense(node, :keyword)
        end
      end
    end
  end
end
