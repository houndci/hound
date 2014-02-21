require 'sentry-raven'

module Monitorable
  def error(job, exception)
    monitor.capture_exception(exception)
  end

  private

  def monitor
    Raven
  end
end
