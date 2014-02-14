require 'sentry-raven'

class BuildJob
  def initialize(build_runner, monitor = Raven)
    @build_runner = build_runner
    @monitor = monitor
  end

  def perform
    build_runner.run
  end

  def error(job, exception)
    monitor.capture_exception(exception)
  end

  private

  attr_reader :build_runner, :monitor
end
