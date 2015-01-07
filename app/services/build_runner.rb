class BuildRunner
  pattr_initialize :payload

  def run
    if repo && relevant_pull_request?
      create_pending_status
      repo.builds.create!(
        violations: violations,
        pull_request_number: payload.pull_request_number,
        commit_sha: payload.head_sha,
      )
      commenter.comment_on_violations(priority_violations)
      create_success_status
      track_reviewed_repo_for_each_user
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
    violations.take(ENV["MAX_COMMENTS"].to_i)
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
