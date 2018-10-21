module Buildable
  def perform(payload_data)
    payload = Payload.new(payload_data)

    unless blacklisted?(payload)
      UpdateRepoStatus.call(payload)
      StartBuild.call(payload)
    end
  end

  def after_retry_exhausted
    payload = Payload.new(*arguments)
    repo = Repo.active.find_by(github_id: payload.github_repo_id)
    github_auth = GitHubAuth.new(repo)
    commit_status = CommitStatus.new(
      repo_name: payload.full_repo_name,
      sha: payload.head_sha,
      token: github_auth.token,
    )
    commit_status.set_internal_error
  end

  private

  def blacklisted?(payload)
    BlacklistedPullRequest.where(
      full_repo_name: payload.full_repo_name,
      pull_request_number: payload.pull_request_number,
    ).any?
  end
end
