# vim:fileencoding=utf-8

require 'optparse'

module Resque
  module Scheduler
    CLI_OPTIONS_ENV_MAPPING = {
      app_name: 'APP_NAME',
      background: 'BACKGROUND',
      dynamic: 'DYNAMIC_SCHEDULE',
      env: 'RAILS_ENV',
      initializer_path: 'INITIALIZER_PATH',
      logfile: 'LOGFILE',
      logformat: 'LOGFORMAT',
      quiet: 'QUIET',
      pidfile: 'PIDFILE',
      poll_sleep_amount: 'RESQUE_SCHEDULER_INTERVAL',
      verbose: 'VERBOSE'
    }

    class Cli
      BANNER = <<-EOF.gsub(/ {6}/, '')
      Usage: resque-scheduler [options]

      Runs a resque scheduler process directly (rather than via rake).

      EOF
      OPTIONS = [
        {
          args: ['-n', '--app-name [APP_NAME]',
                 'Application name for procline'],
          callback: ->(options) { ->(n) { options[:app_name] = n } }
        },
        {
          args: ['-B', '--background', 'Run in the background [BACKGROUND]'],
          callback: ->(options) { ->(b) { options[:background] = b } }
        },
        {
          args: ['-D', '--dynamic-schedule',
                 'Enable dynamic scheduling [DYNAMIC_SCHEDULE]'],
          callback: ->(options) { ->(d) { options[:dynamic] = d } }
        },
        {
          args: ['-E', '--environment [RAILS_ENV]', 'Environment name'],
          callback: ->(options) { ->(e) { options[:env] = e } }
        },
        {
          args: ['-I', '--initializer-path [INITIALIZER_PATH]',
                 'Path to optional initializer ruby file'],
          callback: ->(options) { ->(i) { options[:initializer_path] = i } }
        },
        {
          args: ['-i', '--interval [RESQUE_SCHEDULER_INTERVAL]',
                 'Interval for checking if a scheduled job must run'],
          callback: ->(options) { ->(i) { options[:poll_sleep_amount] = i } }
        },
        {
          args: ['-l', '--logfile [LOGFILE]', 'Log file name'],
          callback: ->(options) { ->(l) { options[:logfile] = l } }
        },
        {
          args: ['-F', '--logformat [LOGFORMAT]', 'Log output format'],
          callback: ->(options) { ->(f) { options[:logformat] = f } }
        },
        {
          args: ['-P', '--pidfile [PIDFILE]', 'PID file name'],
          callback: ->(options) { ->(p) { options[:pidfile] = p } }
        },
        {
          args: ['-q', '--quiet', 'Run with minimal output [QUIET]'],
          callback: ->(options) { ->(q) { options[:quiet] = q } }
        },
        {
          args: ['-v', '--verbose', 'Run with verbose output [VERBOSE]'],
          callback: ->(options) { ->(v) { options[:verbose] = v } }
        }
      ].freeze

      def self.run!(argv = ARGV, env = ENV)
        new(argv, env).run!
      end

      def initialize(argv = ARGV, env = ENV)
        @argv = argv
        @env = env
      end

      def run!
        pre_run
        run_forever
      end

      def pre_run
        parse_options
        pre_setup
        setup_env
      end

      def parse_options
        option_parser.parse!(argv.dup)
      end

      def pre_setup
        if options[:initializer_path]
          load options[:initializer_path].to_s.strip
        else
          false
        end
      end

      def setup_env
        require_relative 'env'
        runtime_env.setup
      end

      def run_forever
        Resque::Scheduler.run
      end

      private

      attr_reader :argv, :env

      def runtime_env
        @runtime_env ||= Resque::Scheduler::Env.new(options)
      end

      def option_parser
        OptionParser.new do |opts|
          opts.banner = BANNER
          OPTIONS.each do |opt|
            opts.on(*opt[:args], &(opt[:callback].call(options)))
          end
        end
      end

      def options
        @options ||= {}.tap do |o|
          CLI_OPTIONS_ENV_MAPPING.map { |key, envvar| o[key] = env[envvar] }
        end
      end
    end
  end
end
