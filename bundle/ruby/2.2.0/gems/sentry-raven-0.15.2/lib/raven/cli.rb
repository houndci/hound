require 'raven'

module Raven
  class CLI
    def self.test(dsn = nil)
      require 'logger'

      logger = ::Logger.new(STDOUT)
      logger.level = ::Logger::ERROR
      logger.formatter = proc do |_severity, _datetime, _progname, msg|
        "-> #{msg}\n"
      end

      Raven.configuration.logger = logger
      Raven.configuration.timeout = 5
      Raven.configuration.dsn = dsn if dsn

      # wipe out env settings to ensure we send the event
      unless Raven.configuration.send_in_current_environment?
        env_name = Raven.configuration.environments.pop || 'production'
        puts "Setting environment to #{env_name}"
        Raven.configuration.current_environment = env_name
      end

      Raven.configuration.verify!

      puts "Sending a test event:"
      puts ""

      begin
        1 / 0
      rescue ZeroDivisionError => exception
        evt = Raven.capture_exception(exception)
      end

      if evt && !(evt.is_a? Thread)
        if evt.is_a? Hash
          puts "-> event ID: #{evt[:event_id]}"
        else
          puts "-> event ID: #{evt.id}"
        end
      elsif evt #async configuration
        if evt.value.is_a? Hash
          puts "-> event ID: #{evt.value[:event_id]}"
        else
          puts "-> event ID: #{evt.value.id}"
        end
      else
        puts ""
        puts "An error occurred while attempting to send the event."
        exit 1
      end

      puts ""
      puts "Done!"
    end
  end
end
