# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks whether comments have a leading space
      # after the # denoting the start of the comment. The
      # leading space is not required for some RDoc special syntax,
      # like #++, #--, #:nodoc, etc.
      class LeadingCommentSpace < Cop
        MSG = 'Missing space after #.'

        def investigate(processed_source)
          processed_source.comments.each do |comment|
            next unless comment.text =~ /^#+[^#\s=:+-]/
            next if comment.text.start_with?('#!') && comment.loc.line == 1

            add_offense(comment, :expression)
          end
        end

        def autocorrect(comment)
          expr = comment.loc.expression
          b = expr.begin_pos
          hash_mark = Parser::Source::Range.new(expr.source_buffer, b, b + 1)
          @corrections << lambda do |corrector|
            corrector.insert_after(hash_mark, ' ')
          end
        end
      end
    end
  end
end
