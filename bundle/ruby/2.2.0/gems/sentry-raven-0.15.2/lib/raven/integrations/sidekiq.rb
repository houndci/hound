require 'time'
require 'sidekiq'

module Raven
  class Sidekiq
    def call(_worker, msg, _queue)
      started_at = Time.now
      yield
    rescue Exception => ex
      Raven.capture_exception(ex, :extra => { :sidekiq => msg },
                                  :time_spent => Time.now-started_at)
      raise
    end
  end
end

if Sidekiq::VERSION < '3'
  # old behavior
  ::Sidekiq.configure_server do |config|
    config.server_middleware do |chain|
      chain.add ::Raven::Sidekiq
    end
  end
else
  Sidekiq.configure_server do |config|
    config.error_handlers << Proc.new {|ex,context| Raven.capture_exception(ex, :extra => {:sidekiq => context}) }
  end
end
