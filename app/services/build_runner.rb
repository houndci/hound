class BuildRunner
  MAX_COMMENTS = ENV.fetch("MAX_COMMENTS").to_i

  pattr_initialize :payload

  def run
    if repo && relevant_pull_request?
      track_subscribed_build_started
      create_pending_status
      upsert_owner
      repo.builds.create!(
        violations: violations,
        pull_request_number: payload.pull_request_number,
        commit_sha: payload.head_sha,
      )
      commenter.comment_on_violations(priority_violations)
      if violations.empty?
        create_success_status
      else
        create_failed_status
      end
      track_subscribed_build_completed
    end
  rescue RepoConfig::ParserError
    create_config_error_status
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
    @pull_request ||= PullRequest.new(payload, token)
  end

  def token
    @token ||= user_token || ENV["HOUND_GITHUB_TOKEN"]
  end

  def user_token
    user_with_token = repo.users.where.not(token: nil).sample
    user_with_token && user_with_token.token
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
      I18n.t(:success_status, count: violation_count)
    )
  end

  def create_failed_status
    github.create_error_status(
      payload.full_repo_name,
      payload.head_sha,
      I18n.t(:build_error_status, count: violation_count)
    )
  end

  def create_config_error_status
    github.create_error_status(
      payload.full_repo_name,
      payload.head_sha,
      I18n.t(:config_error_status),
      configuration_url
    )
  end

  def upsert_owner
    owner = Owner.upsert(
      github_id: payload.repository_owner_id,
      name: payload.repository_owner_name,
      organization: payload.repository_owner_is_organization?
    )
    repo.update(owner: owner)
  end

  def github
    @github ||= GithubApi.new(token)
  end

  def configuration_url
    Rails.application.routes.url_helpers.configuration_url(host: ENV["HOST"])
  end

  def violation_count
    violations.sum(&:messages_count)
  end
end
