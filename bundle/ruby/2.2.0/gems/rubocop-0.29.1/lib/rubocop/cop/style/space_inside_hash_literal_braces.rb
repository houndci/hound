# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks that braces used for hash literals have or don't have
      # surrounding space depending on configuration.
      class SpaceInsideHashLiteralBraces < Cop
        include SurroundingSpace
        include ConfigurableEnforcedStyle

        MSG = 'Space inside %s.'

        def on_hash(node)
          b_ix = index_of_first_token(node)
          tokens = processed_source.tokens

          # Hash literal with braces?
          return unless tokens[b_ix].type == :tLBRACE

          e_ix = index_of_last_token(node)
          check(tokens[b_ix], tokens[b_ix + 1])
          check(tokens[e_ix - 1], tokens[e_ix]) unless b_ix == e_ix - 1
        end

        private

        def check(t1, t2)
          # No offense if line break inside.
          return if t1.pos.line < t2.pos.line
          return if t2.type == :tCOMMENT # Also indicates there's a line break.

          is_empty_braces = t1.text == '{' && t2.text == '}'
          expect_space = if is_empty_braces
                           cop_config['EnforcedStyleForEmptyBraces'] == 'space'
                         else
                           style == :space
                         end
          if offense?(t1, t2, expect_space)
            incorrect_style_detected(t1, t2, expect_space, is_empty_braces)
          else
            correct_style_detected
          end
        end

        def incorrect_style_detected(t1, t2, expect_space, is_empty_braces)
          brace = (t1.text == '{' ? t1 : t2).pos
          range = expect_space ? brace : space_range(brace)
          add_offense(range, range,
                      message(brace, is_empty_braces, expect_space)) do
            opposite_style_detected
          end
        end

        def offense?(t1, t2, expect_space)
          has_space = space_between?(t1, t2)
          expect_space ? !has_space : has_space
        end

        def message(brace, is_empty_braces, expect_space)
          inside_what = if is_empty_braces
                          'empty hash literal braces'
                        else
                          brace.source
                        end
          problem = expect_space ? 'missing' : 'detected'
          format(MSG, "#{inside_what} #{problem}")
        end

        def autocorrect(range)
          @corrections << lambda do |corrector|
            # It is possible that BracesAroundHashParameters will remove the
            # braces while this cop inserts spaces. This can lead to unwanted
            # changes to the inspected code. If we replace the brace with a
            # brace plus space (rather than just inserting a space), then any
            # removal of the same brace will give us a clobbering error. This
            # in turn will make RuboCop fall back on cop-by-cop
            # auto-correction.  Problem solved.
            case range.source
            when /\s/ then corrector.remove(range)
            when '{' then corrector.replace(range, '{ ')
            else corrector.replace(range, ' }')
            end
          end
        end

        def space_range(token_range)
          if token_range.source == '{'
            range_of_space_to_the_right(token_range)
          else
            range_of_space_to_the_left(token_range)
          end
        end

        def range_of_space_to_the_right(range)
          src = range.source_buffer.source
          end_pos = range.end_pos
          end_pos += 1 while src[end_pos] =~ /[ \t]/
          Parser::Source::Range.new(range.source_buffer,
                                    range.begin_pos + 1, end_pos)
        end

        def range_of_space_to_the_left(range)
          src = range.source_buffer.source
          begin_pos = range.begin_pos
          begin_pos -= 1 while src[begin_pos - 1] =~ /[ \t]/
          Parser::Source::Range.new(range.source_buffer, begin_pos,
                                    range.end_pos - 1)
        end
      end
    end
  end
end
