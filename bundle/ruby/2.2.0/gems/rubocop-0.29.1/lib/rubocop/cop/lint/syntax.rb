# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This is actually not a cop and inspects nothing. It just provides
      # methods to repack Parser's diagnostics/errors into RuboCop's offenses.
      module Syntax
        PseudoSourceRange = Struct.new(:line, :column, :source_line)

        COP_NAME = 'Syntax'.freeze
        ERROR_SOURCE_RANGE = PseudoSourceRange.new(1, 0, '').freeze

        def self.offenses_from_processed_source(processed_source)
          offenses = []

          if processed_source.parser_error
            offenses << offense_from_error(processed_source.parser_error)
          end

          processed_source.diagnostics.each do |diagnostic|
            offenses << offense_from_diagnostic(diagnostic)
          end

          offenses
        end

        def self.offense_from_diagnostic(diagnostic)
          Offense.new(
            diagnostic.level,
            diagnostic.location,
            diagnostic.message,
            COP_NAME
          )
        end

        def self.offense_from_error(error)
          message = beautify_message(error.message)
          Offense.new(:fatal, ERROR_SOURCE_RANGE, message, COP_NAME)
        end

        def self.beautify_message(message)
          message = message.capitalize
          message << '.' unless message.end_with?('.')
          message
        end

        private_class_method :beautify_message
      end
    end
  end
end
