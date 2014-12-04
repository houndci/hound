class BuildRunner
  pattr_initialize :payload

  def run
    if repo && relevant_pull_request?
      validate_config
      repo.builds.create!(
        violations: violations,
        pull_request_number: payload.pull_request_number,
        commit_sha: payload.head_sha,
      )
      commenter.comment_on_violations(violations)
      track_reviewed_repo_for_each_user
    end
  end

  private

  def relevant_pull_request?
    pull_request.opened? || pull_request.synchronize?
  end

  def validate_config
    repo_config.validate

    if repo_config.errors.any?
      message_body = repo_config.errors.join("\n")
      pull_request.add_comment(message_body)
    end
  end

  def repo_config
    @repo_config ||= RepoConfig.new(pull_request.head_commit)
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
end
