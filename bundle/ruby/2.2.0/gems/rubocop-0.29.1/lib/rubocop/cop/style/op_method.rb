# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop makes sure that certain operator methods have their sole
      # parameter named `other`.
      class OpMethod < Cop
        MSG = 'When defining the `%s` operator, name its argument `other`.'

        OP_LIKE_METHODS = [:eql?, :equal?]

        BLACKLISTED = [:+@, :-@, :[], :[]=, :<<]

        TARGET_ARGS = [s(:args, s(:arg, :other)), s(:args, s(:arg, :_other))]

        def on_def(node)
          name, args, _body = *node
          return unless op_method?(name) &&
                        args.children.size == 1 &&
                        !TARGET_ARGS.include?(args)

          add_offense(args.children[0], :expression, format(MSG, name))
        end

        def op_method?(name)
          return false if BLACKLISTED.include?(name)
          name !~ /\A\w/ || OP_LIKE_METHODS.include?(name)
        end
      end
    end
  end
end
