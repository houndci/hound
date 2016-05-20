# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks the . position in multi-line method calls.
      class DotPosition < Cop
        include ConfigurableEnforcedStyle

        def on_send(node)
          return unless node.loc.dot

          if proper_dot_position?(node)
            correct_style_detected
          else
            add_offense(node, :dot) { opposite_style_detected }
          end
        end

        private

        def message(_node)
          'Place the . on the ' +
            case style
            when :leading
              'next line, together with the method name.'
            when :trailing
              'previous line, together with the method call receiver.'
            end
        end

        def proper_dot_position?(node)
          receiver, _method_name, *_args = *node

          receiver_line = receiver.loc.expression.end.line

          if node.loc.selector
            selector_line = node.loc.selector.line
          else
            # l.(1) has no selector, so we use the opening parenthesis instead
            selector_line = node.loc.begin.line
          end

          # receiver and selector are on the same line
          return true if selector_line == receiver_line

          dot_line = node.loc.dot.line

          case style
          when :leading then dot_line == selector_line
          when :trailing then dot_line != selector_line
          end
        end

        def autocorrect(node)
          receiver, _method_name, *_args = *node
          if node.loc.selector
            selector = node.loc.selector
          else
            # l.(1) has no selector, so we use the opening parenthesis instead
            selector = node.loc.begin
          end

          @corrections << lambda do |corrector|
            corrector.remove(node.loc.dot)
            case style
            when :leading
              corrector.insert_before(selector, '.')
            when :trailing
              corrector.insert_after(receiver.loc.expression, '.')
            end
          end
        end
      end
    end
  end
end
