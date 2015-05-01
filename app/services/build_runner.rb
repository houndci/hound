class BuildRunner
  class ExpiredToken < StandardError; end

  pattr_initialize :payload

  def run
    if repo && relevant_pull_request?
      review_pull_request
    end
  rescue RepoConfig::ParserError
    create_config_error_status
  rescue Octokit::Unauthorized
    if users_with_token.any?
      reset_token
      raise ExpiredToken
    else
      raise
    end
  end

  private

  def review_pull_request
    track_subscribed_build_started
    create_pending_status
    upsert_owner
    build = create_build
    BuildReport.run(pull_request, build)
  end

  def relevant_pull_request?
    pull_request.opened? || pull_request.synchronize?
  end

  def violations
    @violations ||= style_checker.violations
  end

  def style_checker
    StyleChecker.new(pull_request)
  end

  def create_build
    repo.builds.create!(
      violations: violations,
      pull_request_number: payload.pull_request_number,
      commit_sha: payload.head_sha,
    )
  end

  def pull_request
    @pull_request ||= PullRequest.new(payload, token)
  end

  def token
    @token ||= user_token || ENV["HOUND_GITHUB_TOKEN"]
  end

  def user_token
    user = users_with_token.sample
    user && user.token
  end

  def users_with_token
    repo.users.where.not(token: nil)
  end

  def repo
    @repo ||= Repo.active.find_and_update(
      payload.github_repo_id,
      payload.full_repo_name,
    )
  end

  def reset_token
    token_user = repo.users.detect { |user| user.token == token }
    token_user.update_columns(token: nil)

    @token = nil
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
end
