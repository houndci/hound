class BuildRunner
  pattr_initialize :payload

  def run
    if repo && relevant_pull_request?
      track_subscribed_build_started
      create_pending_status
      build = repo.builds.create!(
        pull_request_number: payload.pull_request_number,
        commit_sha: payload.head_sha,
      )
      dispatch_workers(build)
    end
  end

  private

  def relevant_pull_request?
    pull_request.opened? || pull_request.synchronize?
  end

  def violations
    @violations ||= style_checker.violations
  end

  def dispatch_workers(build)
    StyleChecker.new(pull_request, build).run
  end

  def pull_request
    @pull_request ||= PullRequest.new(payload)
  end

  def repo
    @repo ||= Repo.active.
      find_and_update(payload.github_repo_id, payload.full_repo_name)
  end

  def track_subscribed_build_started
    if repo.subscription
      user = repo.subscription.user
      analytics = Analytics.new(user)
      analytics.track_build_started(repo)
    end
  end

  def create_pending_status
    github.create_pending_status(
      payload.full_repo_name,
      payload.head_sha,
      I18n.t(:pending_status)
    )
  end

  def github
    @github ||= GithubApi.new(ENV["HOUND_GITHUB_TOKEN"])
  end
end
