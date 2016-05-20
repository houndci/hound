module Puma
  class TCPLogger
    def initialize(logger, app, quiet=false)
      @logger = logger
      @app = app
      @quiet = quiet
    end

    FORMAT = "%s - %s"

    def log(who, str)
      now = Time.now.strftime("%d/%b/%Y %H:%M:%S")

      @logger.puts "#{now} - #{who} - #{str}"
    end

    def call(env, socket)
      who = env[Const::REMOTE_ADDR]
      log who, "connected" unless @quiet

      env['log'] = lambda { |str| log(who, str) }

      begin
        @app.call env, socket
      rescue Object => e
        log who, "exception: #{e.message} (#{e.class})"
      else
        log who, "disconnected" unless @quiet
      end
    end
  end
end
