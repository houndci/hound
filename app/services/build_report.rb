class BuildReport
  def self.run(pull_request:, build:, token:)
    new(pull_request: pull_request, build: build, token: token).run
  end

  def initialize(pull_request:, build:, token:)
    @build = build
    @pull_request = pull_request
    @token = token
    @commenter = Commenter.new(pull_request)
  end

  def run
    if build.completed?
      commenter.comment_on_violations(priority_violations)
      set_commit_status
      track_subscribed_build_completed
    end
  end

  private

  attr_reader :build, :commenter, :token, :pull_request

  def priority_violations
    build.violations.take(Hound::MAX_COMMENTS)
  end

  def track_subscribed_build_completed
    if build.repo.subscription
      user = build.repo.subscription.user
      analytics = Analytics.new(user)
      analytics.track_build_completed(build.repo)
    end
  end

  def set_commit_status
    if fail_build?
      commit_status.set_failure(build.violations_count)
    else
      commit_status.set_success(build.violations_count)
    end
  end

  def fail_build?
    hound_config.fail_on_violations? && build.violations_count > 0
  end

  def hound_config
    HoundConfig.new(pull_request.head_commit)
  end

  def commit_status
    CommitStatus.new(
      repo_name: build.repo_name,
      sha: build.commit_sha,
      token: token,
    )
  end
end
