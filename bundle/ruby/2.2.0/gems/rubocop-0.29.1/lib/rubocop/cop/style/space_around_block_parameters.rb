# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks the spacing inside and after block parameters pipes.
      #
      # @example
      #
      #   # bad
      #   {}.each { | x,  y |puts x }
      #
      #   # good
      #   {}.each { |x, y| puts x }
      class SpaceAroundBlockParameters < Cop
        include ConfigurableEnforcedStyle

        def on_block(node)
          _method, args, body = *node
          opening_pipe, closing_pipe = args.loc.begin, args.loc.end
          return unless !args.children.empty? && opening_pipe

          check_inside_pipes(args.children, opening_pipe, closing_pipe)

          if body
            check_space(closing_pipe.end_pos, body.loc.expression.begin_pos,
                        closing_pipe, 'after closing `|`')
          end

          check_each_arg(args)
        end

        private

        def parameter_name
          'EnforcedStyleInsidePipes'
        end

        def check_inside_pipes(args, opening_pipe, closing_pipe)
          first, last = args.first.loc.expression, args.last.loc.expression

          if style == :no_space
            check_no_space(opening_pipe.end_pos, first.begin_pos,
                           'Space before first')
            check_no_space(last.end_pos, closing_pipe.begin_pos,
                           'Space after last')
          elsif style == :space
            check_space(opening_pipe.end_pos, first.begin_pos, first,
                        'before first block parameter')
            check_space(last.end_pos, closing_pipe.begin_pos, last,
                        'after last block parameter')
            check_no_space(opening_pipe.end_pos, first.begin_pos - 1,
                           'Extra space before first')
            check_no_space(last.end_pos + 1, closing_pipe.begin_pos,
                           'Extra space after last')
          end
        end

        def check_each_arg(args)
          args.children[1..-1].each do |arg|
            expr = arg.loc.expression
            check_no_space(range_with_surrounding_space(expr, :left).begin_pos,
                           expr.begin_pos - 1, 'Extra space before')
          end
        end

        def check_space(space_begin_pos, space_end_pos, range, msg)
          return if space_begin_pos != space_end_pos

          add_offense(range, range, "Space #{msg} missing.")
        end

        def check_no_space(space_begin_pos, space_end_pos, msg)
          return if space_begin_pos >= space_end_pos

          range = Parser::Source::Range.new(processed_source.buffer,
                                            space_begin_pos, space_end_pos)
          add_offense(range, range, "#{msg} block parameter detected.")
        end

        def autocorrect(range)
          @corrections << lambda do |corrector|
            case range.source
            when /^\s+$/ then corrector.remove(range)
            else              corrector.insert_after(range, ' ')
            end
          end
        end
      end
    end
  end
end
