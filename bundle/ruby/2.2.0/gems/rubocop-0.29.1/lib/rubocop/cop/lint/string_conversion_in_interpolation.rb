# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for string conversion in string interpolation,
      # which is redundant.
      #
      # @example
      #
      #   "result is #{something.to_s}"
      class StringConversionInInterpolation < Cop
        MSG_DEFAULT = 'Redundant use of `Object#to_s` in interpolation.'
        MSG_SELF = 'Use `self` instead of `Object#to_s` in interpolation.'

        def on_dstr(node)
          node.children.select { |n| n.type == :begin }.each do |begin_node|
            final_node = begin_node.children.last
            next unless final_node && final_node.type == :send

            receiver, method_name, *args = *final_node
            next unless method_name == :to_s && args.empty?

            add_offense(
              final_node,
              :selector,
              receiver ? MSG_DEFAULT : MSG_SELF
            )
          end
        end

        private

        def autocorrect(node)
          @corrections << lambda do |corrector|
            receiver, _method_name, *_args = *node
            corrector.replace(
              node.loc.expression,
              if receiver
                receiver.loc.expression.source
              else
                'self'
              end
            )
          end
        end
      end
    end
  end
end
