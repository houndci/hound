# encoding: utf-8

module RuboCop
  module Cop
    module Rails
      # This cop checks for the use of output calls like puts and print
      class Output < Cop
        MSG = 'Do not write to stdout. Use Rails\' logger if you want to log.'

        BLACKLIST = [:puts,
                     :print,
                     :p,
                     :pp,
                     :pretty_print]

        def on_send(node)
          receiver, method_name, *args = *node
          return unless receiver.nil? &&
                        !args.empty? &&
                        BLACKLIST.include?(method_name)

          add_offense(node, :selector)
        end
      end
    end
  end
end
