# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cops checks for indentation that doesn't use two spaces.
      #
      # @example
      #
      #   class A
      #    def test
      #     puts 'hello'
      #    end
      #   end
      class IndentationWidth < Cop # rubocop:disable Metrics/ClassLength
        include AutocorrectAlignment
        include OnMethodDef
        include CheckAssignment
        include IfNode
        include AccessModifierNode

        def on_rescue(node)
          _begin_node, *rescue_nodes, else_node = *node
          rescue_nodes.each do |rescue_node|
            _, _, body = *rescue_node
            check_indentation(rescue_node.loc.keyword, body)
          end
          check_indentation(node.loc.else, else_node)
        end

        def on_ensure(node)
          _body, ensure_body = *node
          check_indentation(node.loc.keyword, ensure_body)
        end

        def on_kwbegin(node)
          # Check indentation against end keyword but only if it's first on its
          # line.
          return unless begins_its_line?(node.loc.end)
          check_indentation(node.loc.end, node.children.first)
        end

        def on_block(node)
          _method, _args, body = *node
          # Check body against end/} indentation. Checking against variable
          # assignments, etc, would be more difficult. The end/} must be at the
          # beginning of its line.
          loc = node.loc
          check_indentation(loc.end, body) if begins_its_line?(loc.end)
        end

        def on_module(node)
          _module_name, *members = *node
          members.each { |m| check_indentation(node.loc.keyword, m) }
        end

        def on_class(node)
          _class_name, _base_class, *members = *node
          members.each { |m| check_indentation(node.loc.keyword, m) }
        end

        def on_send(node)
          super
          receiver, method_name, *args = *node
          return unless visibility_and_def_on_same_line?(receiver, method_name,
                                                         args)

          _method_name, _args, body = *args.first
          check_indentation(node.loc.expression, body)
          ignore_node(args.first)
        end

        def on_method_def(node, _method_name, _args, body)
          check_indentation(node.loc.keyword, body) unless ignored_node?(node)
        end

        def on_for(node)
          _variable, _collection, body = *node
          check_indentation(node.loc.keyword, body)
        end

        def on_while(node, base = node)
          _condition, body = *node
          return unless node.loc.keyword.begin_pos ==
                        node.loc.expression.begin_pos

          check_indentation(base.loc, body)
        end

        alias_method :on_until, :on_while

        def on_case(node)
          _condition, *branches = *node
          latest_when = nil
          branches.compact.each do |b|
            if b.type == :when
              # TODO: Revert to the original expression once the fix in Rubinius
              #   is released.
              #
              # Originally this expression was:
              #
              #   *_conditions, body = *b
              #
              # However it fails on Rubinius 2.2.9 due to its bug:
              #
              #   RuntimeError:
              #     can't modify frozen instance of Array
              #   # kernel/common/array.rb:988:in `pop'
              #   # ./lib/rubocop/cop/style/indentation_width.rb:99:in `on_case'
              #
              # It seems to be fixed on the current master (0a92c3c).
              body = b.children.last

              # Check "when" body against "when" keyword indentation.
              check_indentation(b.loc.keyword, body)
              latest_when = b
            else
              # Since it's not easy to get the position of the "else" keyword,
              # we check "else" body against latest "when" keyword indentation.
              check_indentation(latest_when.loc.keyword, b)
            end
          end
        end

        def on_if(node, base = node)
          return if ignored_node?(node)
          return if ternary_op?(node)
          return if modifier_if?(node)

          case node.loc.keyword.source
          when 'if', 'elsif' then _condition, body, else_clause = *node
          when 'unless'      then _condition, else_clause, body = *node
          else                    _condition, body = *node
          end

          check_if(node, body, else_clause, base.loc) if body
        end

        private

        def check_assignment(node, rhs)
          # If there are method calls chained to the right hand side of the
          # assignment, we let rhs be the receiver of those method calls before
          # we check its indentation.
          rhs = first_part_of_call_chain(rhs)
          return unless rhs

          end_config = config.for_cop('Lint/EndAlignment')
          style = end_config['Enabled'] ? end_config['AlignWith'] : 'keyword'
          base = style == 'variable' ? node : rhs

          case rhs.type
          when :if            then on_if(rhs, base)
          when :while, :until then on_while(rhs, base)
          else                     return
          end

          ignore_node(rhs)
        end

        def check_if(node, body, else_clause, base_loc)
          return if ternary_op?(node)

          check_indentation(base_loc, body)
          return unless else_clause

          # If the else clause is an elsif, it will get its own on_if call so
          # we don't need to process it here.
          return if elsif?(else_clause)

          check_indentation(node.loc.else, else_clause)
        end

        def check_indentation(base_loc, body_node)
          return unless indentation_to_check?(base_loc, body_node)

          indentation = body_node.loc.column - base_loc.column
          @column_delta = configured_indentation_width - indentation
          return if @column_delta == 0

          # This cop only auto-corrects the first statement in a def body, for
          # example.
          if body_node.type == :begin && !(body_node.loc.begin &&
                                           body_node.loc.begin.is?('('))
            body_node = body_node.children.first
          end

          expr = body_node.loc.expression
          begin_pos, ind = expr.begin_pos, expr.begin_pos - indentation
          pos = indentation >= 0 ? ind..begin_pos : begin_pos..ind

          r = Parser::Source::Range.new(expr.source_buffer, pos.begin, pos.end)
          add_offense(body_node, r,
                      format("Use #{configured_indentation_width} (not %d) " \
                             'spaces for indentation.', indentation))
        end

        def indentation_to_check?(base_loc, body_node)
          return false unless body_node

          # Don't check if expression is on same line as "then" keyword, etc.
          return false if body_node.loc.line == base_loc.line

          return false if starts_with_access_modifier?(body_node)

          # Don't check indentation if the line doesn't start with the body.
          # For example, lines like "else do_something".
          first_char_pos_on_line = body_node.loc.expression.source_line =~ /\S/
          return false unless body_node.loc.column == first_char_pos_on_line

          true
        end

        def starts_with_access_modifier?(body_node)
          body_node.type == :begin && modifier_node?(body_node.children.first)
        end

        def configured_indentation_width
          cop_config['Width']
        end
      end
    end
  end
end
