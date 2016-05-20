# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cops checks for two or more consecutive blank lines.
      class EmptyLines < Cop
        MSG = 'Extra blank line detected.'
        LINE_OFFSET = 2

        def investigate(processed_source)
          return if processed_source.tokens.empty?

          prev_line = 1

          processed_source.tokens.sort_by { |t| t.pos.line }.each do |token|
            cur_line = token.pos.line

            line_diff = cur_line - prev_line

            if line_diff > LINE_OFFSET
              # we need to be wary of comments since they
              # don't show up in the tokens
              ((prev_line + 1)...cur_line).each do |line|
                # we check if the prev and current lines are empty
                next unless processed_source[line - 2].empty? &&
                            processed_source[line - 1].empty?

                range = source_range(processed_source.buffer, line, 0)
                add_offense(range, range)
              end
            end

            prev_line = cur_line
          end
        end

        def autocorrect(range)
          @corrections << ->(corrector) { corrector.remove(range) }
        end
      end
    end
  end
end
