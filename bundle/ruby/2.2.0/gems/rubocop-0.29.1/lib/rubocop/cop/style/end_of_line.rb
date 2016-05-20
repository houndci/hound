# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for Windows-style line endings in the source code.
      class EndOfLine < Cop
        MSG = 'Carriage return character detected.'

        def investigate(processed_source)
          processed_source.raw_source.each_line.with_index do |line, index|
            next unless line =~ /\r$/

            range =
              source_range(processed_source.buffer, index + 1, 0, line.length)
            add_offense(nil, range, MSG)
            # Usually there will be carriage return characters on all or none
            # of the lines in a file, so we report only one offense.
            break
          end
        end
      end
    end
  end
end
