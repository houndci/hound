class BuildRunner
  MAX_COMMENTS = ENV.fetch("MAX_COMMENTS").to_i

  pattr_initialize :payload

  def run
    if repo && relevant_pull_request?
      track_subscribed_build_started
      create_pending_status
      repo.builds.create!(
        violations: violations,
        pull_request_number: payload.pull_request_number,
        commit_sha: payload.head_sha,
      )
      commenter.comment_on_violations(priority_violations)
      create_success_status
      upsert_owner
      track_subscribed_build_completed
    end
  end

  private

  def relevant_pull_request?
    pull_request.opened? || pull_request.synchronize?
  end

  def violations
    @violations ||= style_checker.violations
  end

  def priority_violations
    violations.take(MAX_COMMENTS)
  end

  def style_checker
    StyleChecker.new(pull_request)
  end

  def commenter
    Commenter.new(pull_request)
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

  def track_subscribed_build_completed
    if repo.subscription
      user = repo.subscription.user
      analytics = Analytics.new(user)
      analytics.track_build_completed(repo)
    end
  end

  def create_pending_status
    github.create_pending_status(
      payload.full_repo_name,
      payload.head_sha,
      I18n.t(:pending_status)
    )
  end

  def create_success_status
    github.create_success_status(
      payload.full_repo_name,
      payload.head_sha,
      I18n.t(:success_status)
    )
  end

  def upsert_owner
    Owner.upsert(
      github_id: payload.repository_owner_id,
      name: payload.repository_owner_name,
      organization: payload.repository_owner_is_organization?
    )
  end

  def github
    @github ||= GithubApi.new(ENV["PRIVATE_GITHUB_TOKEN"])
  end
end
