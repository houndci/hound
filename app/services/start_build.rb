class StartBuild
  static_facade :call
  pattr_initialize :payload

  def call
    if repo && relevant_pull_request?
      review_pull_request
    end
  rescue Config::ParserError, ConfigContent::ContentError => exception
    report_config_file_as_invalid(exception)
  rescue Octokit::NotFound, Octokit::Unauthorized
    remove_current_user_membership
    raise
  rescue StandardError
    set_internal_error
    raise
  end

  private

  def review_pull_request
    track_subscribed_build_started
    commit_status.set_pending
    owner = upsert_owner

    if repo.private? && owner.past_due?
      commit_status.set_past_due_status(owner.recent_invoice_url)
    else
      build = create_build
      review_files(build)
      if build.file_reviews.empty?
        set_no_violations_status
      end
    end
  end

  def relevant_pull_request?
    pull_request.opened? || pull_request.synchronize?
  end

  def review_files(build)
    ReviewFiles.new(pull_request, build).call
  end

  def create_build
    repo.builds.create!(
      pull_request_number: payload.pull_request_number,
      commit_sha: payload.head_sha,
      payload: payload.build_data.to_json,
      user: github_auth.user,
    )
  end

  def remove_current_user_membership
    if github_auth.user
      repo.remove_membership(github_auth.user)
    end
  end

  def pull_request
    @_pull_request ||= PullRequest.new(payload, github_auth.token)
  end

  def github_auth
    @_github_auth ||= GitHubAuth.new(repo)
  end

  def repo
    @repo ||= Repo.active.find_by(github_id: payload.github_repo_id)
  end

  def track_subscribed_build_started
    if repo.subscription
      user = repo.subscription.user
      analytics = Analytics.new(user)
      analytics.track_build_started(repo)
    end
  end

  def upsert_owner
    Owner.upsert(
      github_id: payload.repository_owner_id,
      name: payload.repository_owner_name,
      organization: payload.repository_owner_is_organization?
    ).tap do |owner|
      repo.update(owner: owner)
    end
  end

  def commit_status
    @commit_status ||= CommitStatus.new(
      repo: repo,
      sha: payload.head_sha,
      github_auth: github_auth,
    )
  end

  def report_config_file_as_invalid(exception)
    ReportInvalidConfig.call(
      pull_request_number: payload.pull_request_number,
      commit_sha: payload.head_sha,
      message: exception.message,
    )
  end

  def set_no_violations_status
    commit_status.set_success(0)
  end

  def set_internal_error
    commit_status.set_internal_error
  end
end
