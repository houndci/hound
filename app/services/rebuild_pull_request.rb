class RebuildPullRequest
  static_facade :call

  def initialize(repo:, pull_request_number:)
    @repo = repo
    @pull_request_number = pull_request_number
  end

  def call
    if latest_build.present?
      SmallBuildJob.perform_async(latest_build.payload)
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
