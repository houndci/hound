# encoding: utf-8

module RuboCop
  module Cop
    module Test
      class ModuleMustBeAClassCop < RuboCop::Cop::Cop
        def on_module(node)
          add_offense(node, :expression, 'Module must be a Class')
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            corrector.replace(node.loc.keyword, 'class')
          end
        end
      end
    end
  end
end
