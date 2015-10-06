# vim:fileencoding=utf-8

require 'mono_logger'

module Resque
  module Scheduler
    # Just builds a logger, with specified verbosity and destination.
    # The simplest example:
    #
    #   Resque::Scheduler::LoggerBuilder.new.build
    class LoggerBuilder
      # Initializes new instance of the builder
      #
      # Pass :opts Hash with
      #   - :quiet if logger needs to be silent for all levels. Default - false
      #   - :verbose if there is a need in debug messages. Default - false
      #   - :log_dev to output logs into a desired file. Default - STDOUT
      #   - :format log format, either 'text' or 'json'. Default - 'text'
      #
      # Example:
      #
      #   LoggerBuilder.new(
      #     :quiet => false, :verbose => true, :log_dev => 'log/scheduler.log'
      #   )
      def initialize(opts = {})
        @quiet = !!opts[:quiet]
        @verbose = !!opts[:verbose]
        @log_dev = opts[:log_dev] || $stdout
        @format = opts[:format] || 'text'
      end

      # Returns an instance of MonoLogger
      def build
        logger = MonoLogger.new(@log_dev)
        logger.level = level
        logger.formatter = send(:"#{@format}_formatter")
        logger
      end

      private

      def level
        if @verbose && !@quiet
          MonoLogger::DEBUG
        elsif !@quiet
          MonoLogger::INFO
        else
          MonoLogger::FATAL
        end
      end

      def text_formatter
        proc do |severity, datetime, _progname, msg|
          "resque-scheduler: [#{severity}] #{datetime.iso8601}: #{msg}\n"
        end
      end

      def json_formatter
        proc do |severity, datetime, progname, msg|
          require 'json'
          JSON.dump(
            name: 'resque-scheduler',
            progname: progname,
            level: severity,
            timestamp: datetime.iso8601,
            msg: msg
          ) + "\n"
        end
      end
    end
  end
end
