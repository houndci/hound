class BuildJob < Struct.new(:build_runner)
  include Monitorable

  def perform
    build_runner.run
  end

  def error(job, exception)
    super
    if exception.is_a? Octokit::NotFound
      job.fail!
    end
  end
end
