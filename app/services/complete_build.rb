class CompleteBuild
  static_facade :call

  def initialize(pull_request:, build:, token:)
    @build = build
    @pull_request = pull_request
    @token = token
  end

  def call
    if build.completed?
      SubmitReview.call(build)
      set_commit_status
      track_subscribed_build_completed
    end
  end

  private

  attr_reader :build, :token, :pull_request

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
    HoundConfig.new(commit: pull_request.head_commit, owner: build.repo.owner)
  end

  def commit_status
    CommitStatus.new(
      repo_name: build.repo_name,
      sha: build.commit_sha,
      token: token,
    )
  end
end
