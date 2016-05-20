# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks whether constant names are written using
      # SCREAMING_SNAKE_CASE.
      #
      # To avoid false positives, it ignores cases in which we cannot know
      # for certain the type of value that would be assigned to a constant.
      class ConstantName < Cop
        MSG = 'Use SCREAMING_SNAKE_CASE for constants.'
        SNAKE_CASE = /^[\dA-Z_]+$/

        def on_casgn(node)
          _scope, const_name, value = *node

          # We cannot know the result of method calls like
          # NewClass = something_that_returns_a_class
          # It's also ok to assign a class constant another class constant
          # SomeClass = SomeOtherClass
          return if value && [:send, :block, :const].include?(value.type)

          add_offense(node, :name) if const_name !~ SNAKE_CASE
        end
      end
    end
  end
end
