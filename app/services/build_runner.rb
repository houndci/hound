class BuildRunner
  ExpiredToken = Class.new(StandardError)

  pattr_initialize :payload

  def run
    if repo && relevant_pull_request?
      review_pull_request
    end
  rescue RepoConfig::ParserError => e
    commit_status.set_config_error(e.filename)
  rescue Octokit::Unauthorized
    if users_with_token.any?
      reset_token
      raise ExpiredToken
    else
      raise
    end
  rescue Octokit::NotFound
    if token != Hound::GITHUB_TOKEN
      remove_repo_from_user
    end
    raise
  end

  private

  def review_pull_request
    track_subscribed_build_started
    commit_status.set_pending
    upsert_owner
    build = create_build
    review_files(build)
    BuildReport.run(pull_request: pull_request, build: build, token: token)
  end

  def relevant_pull_request?
    pull_request.opened? || pull_request.synchronize?
  end

  def review_files(build)
    StyleChecker.new(pull_request, build).review_files
  end

  def create_build
    repo.builds.create!(
      pull_request_number: payload.pull_request_number,
      commit_sha: payload.head_sha,
      payload: payload.build_data.to_json,
      user: current_user_with_token,
    )
  end

  def pull_request
    @pull_request ||= PullRequest.new(payload, token)
  end

  def token
    @token ||= current_user_with_token.try(:token) || Hound::GITHUB_TOKEN
  end

  def current_user_with_token
    @current_user_with_token ||= users_with_token.sample
  end

  def users_with_token
    repo.users.where.not(token: nil)
  end

  def last_token_user
    repo.users.detect { |user| user.token == token }
  end

  def repo
    @repo ||= Repo.active.find_and_update(
      payload.github_repo_id,
      payload.full_repo_name,
    )
  end

  def reset_token
    last_token_user.update_columns(token: nil)
    @token = nil
  end

  def remove_repo_from_user
    last_token_user.repos.destroy(repo)
    @token = nil
  end

  def track_subscribed_build_started
    if repo.subscription
      user = repo.subscription.user
      analytics = Analytics.new(user)
      analytics.track_build_started(repo)
    end
  end

  def upsert_owner
    owner = Owner.upsert(
      github_id: payload.repository_owner_id,
      name: payload.repository_owner_name,
      organization: payload.repository_owner_is_organization?
    )
    repo.update(owner: owner)
  end

  def commit_status
    @commit_status ||= CommitStatus.new(
      repo_name: payload.full_repo_name,
      sha: payload.head_sha,
      token: token,
    )
  end
end
