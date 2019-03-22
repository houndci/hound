module Buildable
  extend ActiveSupport::Concern

  included do
    sidekiq_retries_exhausted do |job|
      unless job["error_message"].match?(%r{/statuses/\w+: 404 - Not Found})
        set_error_status
      end
    end
  end

  def perform(payload_data)
    payload = Payload.new(payload_data)

    unless blacklisted?(payload)
      UpdateRepoStatus.call(payload)
      StartBuild.call(payload)
    end
  end

  private

  def set_error_status
    payload = Payload.new(*arguments)
    repo = Repo.active.find_by(github_id: payload.github_repo_id)
    github_auth = GitHubAuth.new(repo)
    commit_status = CommitStatus.new(
      repo: repo,
      sha: payload.head_sha,
      github_auth: github_auth,
    )
    commit_status.set_internal_error
  end

  def blacklisted?(payload)
    BlacklistedPullRequest.where(
      full_repo_name: payload.full_repo_name,
      pull_request_number: payload.pull_request_number,
    ).any?
  end
end
