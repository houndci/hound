# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks for semicolon (;) preceded by space.
      class SpaceBeforeSemicolon < Cop
        include SpaceBeforePunctuation

        def kind(token)
          'semicolon' if token.type == :tSEMI
        end
      end
    end
  end
end
