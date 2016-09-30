class RebuildPullRequest
  def self.call(*args)
    new(*args).call
  end

  def initialize(repo:, pull_request_number:)
    @repo = repo
    @pull_request_number = pull_request_number
  end

  def call
    if latest_build.present?
      SmallBuildJob.perform_later(latest_build.payload)
    end
  end

  private

  def latest_build
    Build.
      where(repo: @repo, pull_request_number: @pull_request_number).
      order(created_at: :desc).
      first
  end
end
