# encoding: utf-8

module RuboCop
  module Cop
    # This module contains a collection of useful utility methods.
    module Util
      include PathUtil
      extend AST::Sexp

      PROC_NEW_NODE = s(:send, s(:const, nil, :Proc), :new)
      EQUALS_ASGN_NODES = [:lvasgn, :ivasgn, :cvasgn, :gvasgn, :casgn, :masgn]
      SHORTHAND_ASGN_NODES = [:op_asgn, :or_asgn, :and_asgn]
      ASGN_NODES = EQUALS_ASGN_NODES + SHORTHAND_ASGN_NODES

      # http://phrogz.net/programmingruby/language.html#table_18.4
      # Backtick is added last just to help editors parse this code.
      OPERATOR_METHODS = %w(
        | ^ & <=> == === =~ > >= < <= << >>
        + - * / % ** ~ +@ -@ [] []= ! != !~
      ).map(&:to_sym) + [:'`']

      module_function

      def operator?(symbol)
        OPERATOR_METHODS.include?(symbol)
      end

      def strip_quotes(str)
        if str[0] == '"' || str[0] == "'"
          str[0] = ''
          str[-1] = ''
        else
          # we're dealing with %q or %Q
          str[0, 3] = ''
          str[-1] = ''
        end

        str
      end

      def block_length(block_node)
        block_node.loc.end.line - block_node.loc.begin.line
      end

      def comment_line?(line_source)
        line_source =~ /^\s*#/
      end

      def line_range(arg)
        source_range = case arg
                       when Parser::Source::Range
                         arg
                       when Parser::AST::Node
                         arg.loc.expression
                       else
                         fail ArgumentError, "Invalid argument #{arg}"
                       end

        source_range.begin.line..source_range.end.line
      end

      def const_name(node)
        return nil if node.nil? || node.type != :const

        const_names = []
        const_node = node

        loop do
          namespace_node, name = *const_node
          const_names << name
          break unless namespace_node
          break unless namespace_node.is_a?(Parser::AST::Node)
          break if namespace_node.type == :cbase
          const_node = namespace_node
        end

        const_names.reverse.join('::')
      end

      def command?(name, node)
        return unless node.type == :send

        receiver, method_name, _args = *node

        # commands have no explicit receiver
        !receiver && method_name == name
      end

      def lambda?(node)
        fail 'Not a block node' unless node.type == :block

        send_node, _block_args, _block_body = *node

        command?(:lambda, send_node)
      end

      def proc?(node)
        fail 'Not a block node' unless node.type == :block

        send_node, _block_args, _block_body = *node

        command?(:proc, send_node) || send_node == PROC_NEW_NODE
      end

      def lambda_or_proc?(node)
        lambda?(node) || proc?(node)
      end

      def parentheses?(node)
        node.loc.respond_to?(:end) && node.loc.end
      end

      def on_node(syms, sexp, excludes = [])
        yield sexp if Array(syms).include?(sexp.type)

        return if Array(excludes).include?(sexp.type)

        sexp.children.each do |elem|
          next unless elem.is_a?(Parser::AST::Node)
          on_node(syms, elem, excludes) { |s| yield s }
        end
      end

      def source_range(source_buffer, line_number, column, length = 1)
        if column.is_a?(Range)
          column_index = column.begin
          length = numeric_range_size(column)
        else
          column_index = column
        end

        preceding_line_numbers = (1...line_number)

        line_begin_pos = preceding_line_numbers.reduce(0) do |pos, line|
          pos + source_buffer.source_line(line).length + 1
        end

        begin_pos = line_begin_pos + column_index
        end_pos = begin_pos + length

        Parser::Source::Range.new(source_buffer, begin_pos, end_pos)
      end

      def range_with_surrounding_comma(range, side = :both, buffer = nil)
        buffer ||= @processed_source.buffer
        src = buffer.source

        if side == :both
          go_left, go_right = true, true
        else
          go_left = side == :left
          go_right = side == :right
        end

        begin_pos, end_pos = range.begin_pos, range.end_pos
        begin_pos -= 1 if go_left && src[begin_pos - 1] == ','
        end_pos += 1 if go_right && src[end_pos] == ','

        Parser::Source::Range.new(buffer, begin_pos, end_pos)
      end

      def range_with_surrounding_space(range, side = :both, buffer = nil)
        buffer ||= @processed_source.buffer
        src = buffer.source

        if side == :both
          go_left, go_right = true, true
        else
          go_left = side == :left
          go_right = side == :right
        end

        begin_pos, end_pos = range.begin_pos, range.end_pos
        begin_pos -= 1 while go_left && src[begin_pos - 1] =~ /[ \t]/
        begin_pos -= 1 if go_left && src[begin_pos - 1] == "\n"
        end_pos += 1 while go_right && src[end_pos] =~ /[ \t]/
        end_pos += 1 if go_right && src[end_pos] == "\n"
        Parser::Source::Range.new(buffer, begin_pos, end_pos)
      end

      def begins_its_line?(range)
        source_before_end = range.source_buffer.source[0...range.begin_pos]
        source_before_end =~ /\n\s*\Z/
      end

      def within_node?(inner, outer)
        o, i = outer.loc.expression, inner.loc.expression
        i.begin_pos >= o.begin_pos && i.end_pos <= o.end_pos
      end

      # Returns, for example, a bare `if` node if the given node is an `if`
      # with calls chained to the end of it.
      def first_part_of_call_chain(node)
        while node
          case node.type
          when :send
            receiver, _method_name, _args = *node
            node = receiver
          when :block
            method, _args, _body = *node
            node = method
          else
            break
          end
        end
        node
      end

      # Range#size is not available prior to Ruby 2.0.
      def numeric_range_size(range)
        size = range.end - range.begin
        size += 1 unless range.exclude_end?
        size = 0 if size < 0
        size
      end
    end
  end
end
