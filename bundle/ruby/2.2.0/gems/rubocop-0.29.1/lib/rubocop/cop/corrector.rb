# encoding: utf-8

module RuboCop
  module Cop
    # This class takes a source buffer and rewrite its source
    # based on the different correction rules supplied.
    #
    # Important!
    # The nodes modified by the corrections should be part of the
    # AST of the source_buffer.
    class Corrector
      #
      # @param source_buffer [Parser::Source::Buffer]
      # @param corrections [Array(#call)]
      #   Array of Objects that respond to #call. They will receive the
      #   corrector itself and should use its method to modify the source.
      #
      # @example
      #
      #   class AndOrCorrector
      #     def initialize(node)
      #       @node = node
      #     end
      #
      #     def call(corrector)
      #       replacement = (@node.type == :and ? '&&' : '||')
      #       corrector.replace(@node.loc.operator, replacement)
      #     end
      #   end
      #
      #   corrections = [AndOrCorrector.new(node)]
      #   corrector = Corrector.new(source_buffer, corrections)
      def initialize(source_buffer, corrections)
        @source_buffer = source_buffer
        @corrections = corrections
        @source_rewriter = Parser::Source::Rewriter.new(source_buffer)
      end

      # Does the actual rewrite and returns string corresponding to
      # the rewritten source.
      #
      # @return [String]
      # TODO: Handle conflict exceptions raised from the Source::Rewriter
      def rewrite
        @corrections.each do |correction|
          correction.call(self)
        end

        @source_rewriter.process
      end

      # Removes the source range.
      #
      # @param [Parser::Source::Range] range
      def remove(range)
        @source_rewriter.remove(range)
      end

      # Inserts new code before the given source range.
      #
      # @param [Parser::Source::Range] range
      # @param [String] content
      def insert_before(range, content)
        @source_rewriter.insert_before(range, content)
      end

      # Inserts new code after the given source range.
      #
      # @param [Parser::Source::Range] range
      # @param [String] content
      def insert_after(range, content)
        @source_rewriter.insert_after(range, content)
      end

      # Replaces the code of the source range `range` with `content`.
      #
      # @param [Parser::Source::Range] range
      # @param [String] content
      def replace(range, content)
        @source_rewriter.replace(range, content)
      end
    end
  end
end
