require 'time'
require 'rack'

module Raven
  # Middleware for Rack applications. Any errors raised by the upstream
  # application will be delivered to Sentry and re-raised.
  #
  # Synopsis:
  #
  #   require 'rack'
  #   require 'raven'
  #
  #   Raven.configure do |config|
  #     config.server = 'http://my_dsn'
  #   end
  #
  #   app = Rack::Builder.app do
  #     use Raven::Rack
  #     run lambda { |env| raise "Rack down" }
  #   end
  #
  # Use a standard Raven.configure call to configure your server credentials.
  class Rack

    def self.capture_type(exception, env, options = {})
      if env['raven.requested_at']
        options[:time_spent] = Time.now - env['raven.requested_at']
      end
      Raven.capture_type(exception, options) do |evt|
        evt.interface :http do |int|
          int.from_rack(env)
        end
      end
    end
    class << self
      alias_method :capture_message, :capture_type
      alias_method :capture_exception, :capture_type
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      # clear context at the beginning of the request to ensure a clean slate
      Context.clear!

      # store the current environment in our local context for arbitrary
      # callers
      env['raven.requested_at'] = Time.now
      Raven.rack_context(env)

      begin
        response = @app.call(env)
      rescue Error
        raise # Don't capture Raven errors
      rescue Exception => e
        Raven.logger.debug "Collecting %p: %s" % [ e.class, e.message ]
        Raven::Rack.capture_exception(e, env)
        raise
      end

      error = env['rack.exception'] || env['sinatra.error'] || env['action_dispatch.exception']

      Raven::Rack.capture_exception(error, env) if error

      response
    end
  end
end
