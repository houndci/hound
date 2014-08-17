class BuildRunner
  vattr_initialize :payload

  def run
    if repo && relevant_pull_request?
      repo.builds.create!(violations: violations)
      commenter.comment_on_violations(violations)
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

  def style_checker
    StyleChecker.new(pull_request)
  end

  def commenter
    Commenter.new(pull_request)
  end

  def pull_request
    @pull_request ||= PullRequest.new(payload, ENV['HOUND_GITHUB_TOKEN'])
  end

  def repo
    @repo ||= Repo.active.where(github_id: payload.github_repo_id).first
  end

  def track_reviewed_repo_for_each_user
    repo.users.each do |user|
      analytics = Analytics.new(user)
      analytics.track_reviewed(repo)
    end
  end
end
