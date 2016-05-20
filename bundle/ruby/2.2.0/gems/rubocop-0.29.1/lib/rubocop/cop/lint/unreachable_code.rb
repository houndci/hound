# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for unreachable code.
      # The check are based on the presence of flow of control
      # statement in non-final position in *begin*(implicit) blocks.
      class UnreachableCode < Cop
        MSG = 'Unreachable code detected.'

        NODE_TYPES = [:return, :next, :break, :retry, :redo]
        FLOW_COMMANDS = [:throw, :raise, :fail]

        def on_begin(node)
          expressions = *node

          expressions.each_cons(2) do |e1, e2|
            next unless NODE_TYPES.include?(e1.type) || flow_command?(e1)
            add_offense(e2, :expression)
          end
        end

        private

        def flow_command?(node)
          FLOW_COMMANDS.any? { |c| command?(c, node) }
        end
      end
    end
  end
end
