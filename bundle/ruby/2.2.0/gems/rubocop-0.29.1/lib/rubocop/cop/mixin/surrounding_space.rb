# encoding: utf-8

module RuboCop
  module Cop
    # Common functionality for checking surrounding space.
    module SurroundingSpace
      def space_between?(t1, t2)
        between = Parser::Source::Range.new(t1.pos.source_buffer,
                                            t1.pos.end_pos,
                                            t2.pos.begin_pos).source

        # Check if the range between the tokens starts with a space. It can
        # contain other characters, e.g. a unary plus, but it must start with
        # space.
        between =~ /^\s/
      end

      def index_of_first_token(node)
        b = node.loc.expression.begin
        token_table[[b.line, b.column]]
      end

      def index_of_last_token(node)
        e = node.loc.expression.end
        (0...e.column).to_a.reverse.find do |c|
          ix = token_table[[e.line, c]]
          return ix if ix
        end
      end

      def token_table
        @token_table ||= begin
          table = {}
          @processed_source.tokens.each_with_index do |t, ix|
            table[[t.pos.line, t.pos.column]] = ix
          end
          table
        end
      end
    end
  end
end
