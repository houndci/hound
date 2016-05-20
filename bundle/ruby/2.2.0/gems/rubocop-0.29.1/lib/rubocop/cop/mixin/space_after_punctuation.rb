# encoding: utf-8

module RuboCop
  module Cop
    # Common functionality for cops checking for missing space after
    # punctuation.
    module SpaceAfterPunctuation
      MSG = 'Space missing after %s.'

      def investigate(processed_source)
        processed_source.tokens.each_cons(2) do |t1, t2|
          next unless kind(t1) && t1.pos.line == t2.pos.line &&
                      t2.pos.column == t1.pos.column + offset &&
                      ![:tRPAREN, :tRBRACK].include?(t2.type)

          add_offense(t1, t1.pos, format(MSG, kind(t1)))
        end
      end

      # The normal offset, i.e., the distance from the punctuation
      # token where a space should be, is 1.
      def offset
        1
      end

      def autocorrect(token)
        @corrections << lambda do |corrector|
          corrector.replace(token.pos, token.pos.source + ' ')
        end
      end
    end
  end
end
