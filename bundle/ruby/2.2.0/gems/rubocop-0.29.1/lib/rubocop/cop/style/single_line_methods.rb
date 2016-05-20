# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for single-line method definitions.
      # It can optionally accept single-line methods with no body.
      class SingleLineMethods < Cop
        include OnMethodDef

        MSG = 'Avoid single-line method definitions.'

        def allow_empty?
          cop_config['AllowIfMethodIsEmpty']
        end

        private

        def on_method_def(node, _method_name, _args, body)
          start_line = node.loc.keyword.line
          end_line = node.loc.end.line

          empty_body = body.nil?
          return unless start_line == end_line && !(allow_empty? && empty_body)

          @body = body
          add_offense(node, :expression)
        end

        def autocorrect(node)
          body = @body
          eol_comment = processed_source.comments.find do |c|
            c.loc.line == node.loc.expression.line
          end
          @corrections << lambda do |corrector|
            if body.type == :begin
              body.children.each do |part|
                break_line_before(part.loc.expression, node, corrector, 1)
              end
            else
              break_line_before(body.loc.expression, node, corrector, 1)
            end

            break_line_before(node.loc.end, node, corrector, 0)

            move_comment(eol_comment, node, corrector) if eol_comment
          end
        end

        def break_line_before(range, node, corrector, indent_steps)
          corrector.insert_before(
            range,
            "\n" + ' ' * (node.loc.keyword.column +
                          indent_steps * configured_indentation_width)
          )
        end

        def configured_indentation_width
          config.for_cop('IndentationWidth')['Width']
        end

        def move_comment(eol_comment, node, corrector)
          text = eol_comment.loc.expression.source
          corrector.insert_before(node.loc.expression,
                                  text + "\n" +
                                  ' ' * node.loc.keyword.column)
          corrector.remove(eol_comment.loc.expression)
        end
      end
    end
  end
end
