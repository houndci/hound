class BuildRunner
  pattr_initialize :payload

  def run
    if repo && relevant_pull_request?
      if repo_config.invalid?
        create_failed_build
      else
        run_build
      end
    end
  end

  private

  def relevant_pull_request?
    pull_request.opened? || pull_request.synchronize?
  end

  def create_failed_build
    failure_message = I18n.t("invalid_config")
    create_build([failure_message])

    github.create_failure_status(
      payload.full_repo_name,
      payload.head_sha,
      failure_message
    )
  end

  def repo_config
    @repo_config ||= RepoConfig.new(pull_request.head_commit)
  end

  def create_build(violations)
    repo.builds.create!(
      violations: violations,
      pull_request_number: payload.pull_request_number,
      commit_sha: payload.head_sha
    )
  end

  def run_build
    create_build(style_checker_violations)
    create_pending_status
    commenter.comment_on_violations(style_checker_violations)
    create_success_status
    track_reviewed_repo_for_each_user
  end

  def style_checker_violations
    @violations ||= style_checker.violations
  end

  def style_checker
    StyleChecker.new(pull_request, repo_config)
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

  def track_reviewed_repo_for_each_user
    repo.users.each do |user|
      analytics = Analytics.new(user)
      analytics.track_reviewed(repo)
    end
  end

  def create_pending_status
    github.create_pending_status(
      payload.full_repo_name,
      payload.head_sha,
      "Hound is reviewing changes."
    )
  end

  def create_success_status
    github.create_success_status(
      payload.full_repo_name,
      payload.head_sha,
      "Hound has reviewed the changes."
    )
  end

  def github
    @github ||= GithubApi.new
  end
end
