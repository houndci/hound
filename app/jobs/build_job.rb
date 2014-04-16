class BuildJob < Struct.new(:build_runner)
  include Monitorable

  def perform
    build_runner.run
  end

  def error(job, exception)
    super
    if do_not_retry_exceptions.include?(exception.class)
      job.fail!
    end
  end

  private

  def do_not_retry_exceptions
    [Octokit::NotFound, Octokit::Unauthorized]
  end
end
