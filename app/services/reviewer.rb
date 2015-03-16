class Reviewer
  def self.run(build_worker, file, violations)
    new(build_worker, file, violations).run
  end

  def initialize(build_worker, file, violations)
    @build_worker = build_worker
    @file = file
    @violations = violations
  end

  def run
    # save violations
    # Comment
    create_success_status
    track_subscribed_build_completed
    mark_build_worker_complete
  end

  private

  attr_reader :build_worker, :file, :violations

  def mark_build_worker_complete
    build_worker.update!(completed_at: Time.now)
  end

  def track_subscribed_build_completed
    if repo.subscription
      user = repo.subscription.user
      analytics = Analytics.new(user)
      analytics.track_build_completed(repo)
    end
  end

  def create_success_status
    github.create_success_status(
      repo.full_github_name,
      build.commit_sha,
      I18n.t(:success_status)
    )
  end

  def build
    build_worker.build
  end

  def repo
    build.repo
  end

  def github
    @github ||= GithubApi.new(ENV["HOUND_GITHUB_TOKEN"])
  end
end
