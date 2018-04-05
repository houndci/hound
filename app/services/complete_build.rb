class CompleteBuild
  static_facade :call

  def initialize(pull_request:, build:)
    @build = build
    @pull_request = pull_request
    @commenting_policy = CommentingPolicy.new(pull_request)
  end

  def call
    if build.completed?
      new_violations = priority_violations.select do |violation|
        commenting_policy.comment_on?(violation)
      end
      if new_violations.any? || build.review_errors.any?
        pull_request.make_comments(new_violations, build.review_errors)
      end
      set_commit_status
      track_subscribed_build_completed
    end
  end

  private

  attr_reader :build, :commenting_policy, :pull_request

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
    HoundConfig.new(commit: pull_request.head_commit, owner: build.repo.owner)
  end

  def commit_status
    CommitStatus.new(repo: build.repo, sha: build.commit_sha, user: build.user)
  end
end
