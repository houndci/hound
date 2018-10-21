class CompleteBuild
  static_facade :call
  pattr_initialize :build

  def call
    SubmitReview.call(build)
    set_commit_status
    track_subscribed_build_completed
  end

  private

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
    HoundConfig.new(commit: commit, owner: build.repo.owner)
  end

  def commit
    Commit.new(
      build.repo_name,
      build.commit_sha,
      GitHubApi.new(build.github_auth.token),
    )
  end

  def commit_status
    CommitStatus.new(
      repo: build.repo,
      sha: build.commit_sha,
      github_auth: build.github_auth,
    )
  end
end
