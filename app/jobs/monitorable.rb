require 'sentry-raven'

module Monitorable
  def error(job, exception)
    monitor.capture_exception(exception, extra: { job_id: job.id })
  end

  private

  def monitor
    Raven
  end
end
