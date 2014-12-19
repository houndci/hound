class BuildRunner
  pattr_initialize :payload

  def run
    if repo && relevant_pull_request?
      repo_config.validate

      if repo_config.errors.any?
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
    failure_message = repo_config.errors.join("\n")

    repo.builds.create!(
      violations: [failure_message],
      pull_request_number: payload.pull_request_number,
      commit_sha: payload.head_sha
    )

    github.create_failure_status(
      payload.full_repo_name,
      payload.head_sha,
      failure_message
    )
  end

  def repo_config
    @repo_config ||= RepoConfig.new(pull_request.head_commit)
  end

  def run_build
    repo.builds.create!(
      violations: violations,
      pull_request_number: payload.pull_request_number,
      commit_sha: payload.head_sha,
    )
    create_pending_status
    commenter.comment_on_violations(violations)
    create_success_status
    track_reviewed_repo_for_each_user
  end

  def violations
    @violations ||= style_checker.violations
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
