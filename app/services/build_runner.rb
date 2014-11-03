class BuildRunner
  pattr_initialize :payload

  def run
    if repo && event.relevant?
      each_commit_violations do |commit, violations|
        repo.builds.create!(
          violations: violations,
          pull_request_number: payload.pull_request_number,
          commit_sha: commit.sha,
        )
        Commenter.new(commit).comment_on_violations(violations)
      end
      track_reviewed_repo_for_each_user
    end
  end

  private

  def each_commit_violations
    event.commits.each do |commit|
      yield commit, StyleChecker.new(commit, event.config).violations
    end
  end

  def event
    @event ||= Event.new_from_payload(payload, ENV["HOUND_GITHUB_TOKEN"])
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
