# vim:fileencoding=utf-8

module Resque
  module Scheduler
    module Configuration
      # Allows for block-style configuration
      def configure
        yield self
      end

      # Used in `#load_schedule_job`
      attr_writer :env

      def env
        return @env if @env
        @env ||= Rails.env if defined?(Rails)
        @env ||= ENV['RAILS_ENV']
        @env
      end

      # If true, logs more stuff...
      attr_writer :verbose

      def verbose
        @verbose ||= !!ENV['VERBOSE']
      end

      # If set, produces no output
      attr_writer :quiet

      def quiet
        @quiet ||= !!ENV['QUIET']
      end

      # If set, will write messages to the file
      attr_writer :logfile

      def logfile
        @logfile ||= ENV['LOGFILE']
      end

      # Sets whether to log in 'text' or 'json'
      attr_writer :logformat

      def logformat
        @logformat ||= ENV['LOGFORMAT']
      end

      # If set, will try to update the schedule in the loop
      attr_writer :dynamic

      def dynamic
        @dynamic ||= !!ENV['DYNAMIC_SCHEDULE']
      end

      # If set, will append the app name to procline
      attr_writer :app_name

      def app_name
        @app_name ||= ENV['APP_NAME']
      end

      # Amount of time in seconds to sleep between polls of the delayed
      # queue.  Defaults to 5
      attr_writer :poll_sleep_amount

      def poll_sleep_amount
        @poll_sleep_amount ||=
          Float(ENV.fetch('RESQUE_SCHEDULER_INTERVAL', '5'))
      end
    end
  end
end
