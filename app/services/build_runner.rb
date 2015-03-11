class BuildRunner
  MAX_COMMENTS = ENV.fetch("MAX_COMMENTS").to_i

  pattr_initialize :payload

  def run
    if repo && relevant_pull_request?
      track_subscribed_build_started
      create_pending_status

      # create a build first
      # find violations
      # update build with violations that were found in Hound, not workers
      build = repo.builds.create!(
        violations: violations,
        pull_request_number: payload.pull_request_number,
        commit_sha: payload.head_sha,
      )

      commenter.comment_on_violations(priority_violations)
      # cannot always do this with Iron.io when there are records of workers for the build

      # if build has any pending violations, don't create success
      create_success_status
      upsert_owner
      # this too

      # if build has any pending violations, don't track completed build
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
    # don't include pending
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
    @github ||= GithubApi.new(ENV["HOUND_GITHUB_TOKEN"])
  end
end
