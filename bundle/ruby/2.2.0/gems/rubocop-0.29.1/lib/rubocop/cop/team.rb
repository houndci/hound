# encoding: utf-8

module RuboCop
  module Cop
    # FIXME
    class Team
      attr_reader :errors, :updated_source_file

      alias_method :updated_source_file?, :updated_source_file

      def initialize(cop_classes, config, options = nil)
        @cop_classes = cop_classes
        @config = config
        @options = options || { auto_correct: false, debug: false }
        @errors = []
      end

      def autocorrect?
        @options[:auto_correct]
      end

      def debug?
        @options[:debug]
      end

      def inspect_file(processed_source)
        # If we got any syntax errors, return only the syntax offenses.
        unless processed_source.valid_syntax?
          return Lint::Syntax.offenses_from_processed_source(processed_source)
        end

        commissioner = Commissioner.new(cops, forces)
        offenses = commissioner.investigate(processed_source)
        process_commissioner_errors(processed_source.path, commissioner.errors)
        autocorrect(processed_source.buffer, cops)
        offenses
      end

      def cops
        @cops ||= @cop_classes.each_with_object([]) do |cop_class, instances|
          next unless cop_enabled?(cop_class)
          instances << cop_class.new(@config, @options)
        end
      end

      def forces
        @forces ||= Force.all.each_with_object([]) do |force_class, forces|
          joining_cops = cops.select { |cop| cop.join_force?(force_class) }
          next if joining_cops.empty?
          forces << force_class.new(joining_cops)
        end
      end

      private

      def cop_enabled?(cop_class)
        @config.cop_enabled?(cop_class) ||
          (@options[:only] || []).include?(cop_class.cop_name)
      end

      def autocorrect(buffer, cops)
        @updated_source_file = false
        return unless autocorrect?

        new_source = autocorrect_one_cop(buffer, cops)

        return if new_source == buffer.source

        filename = buffer.name
        File.open(filename, 'w') { |f| f.write(new_source) }
        @updated_source_file = true
      end

      # Does an auto-correction run by correcting for just one cop. The
      # re-running of auto-corrections will make sure that the full set of
      # auto-corrections is tried again after this method has finished.
      def autocorrect_one_cop(buffer, cops)
        cop_with_corrections = cops.find do |cop|
          cop.relevant_file?(buffer.name) && cop.corrections.any?
        end
        if cop_with_corrections
          corrector = Corrector.new(buffer, cop_with_corrections.corrections)
          corrector.rewrite
        else
          buffer.source
        end
      end

      def process_commissioner_errors(file, file_errors)
        file_errors.each do |cop, errors|
          errors.each do |e|
            handle_error(e,
                         "An error occurred while #{cop.name}".color(:red) +
                         " cop was inspecting #{file}.".color(:red))
          end
        end
      end

      def handle_error(e, message)
        @errors << message
        warn message
        if debug?
          puts e.message, e.backtrace
        else
          warn 'To see the complete backtrace run rubocop -d.'
        end
      end
    end
  end
end
