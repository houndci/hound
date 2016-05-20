# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Here we check if the elements of a multi-line array literal are
      # aligned.
      class AlignArray < Cop
        include AutocorrectAlignment

        MSG = 'Align the elements of an array literal if they span more ' \
              'than one line.'

        def on_array(node)
          check_alignment(node.children)
        end
      end
    end
  end
end
