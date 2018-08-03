# frozen_string_literal: true
class PullRequest
  FILE_REMOVED_STATUS = "removed"

  pattr_initialize :payload, :token

  def commit_files
    @commit_files ||= modified_commit_files
  end

  def opened?
    payload.action == "opened"
  end

  def synchronize?
    payload.action == "synchronize"
  end

  def head_commit
    @head_commit ||= Commit.new(repo_name, payload.head_sha, github_api)
  end

  private

  def modified_commit_files
    modified_github_files.map do |github_file|
      CommitFile.new(
        filename: github_file.filename,
        patch: github_file.patch,
        commit: head_commit,
      )
    end
  end

  def modified_github_files
    github_files = github_api.pull_request_files(repo_name, number)

    github_files.select do |github_file|
      github_file.status != FILE_REMOVED_STATUS
    end
  end

  def github_api
    @_github_api ||= GitHubApi.new(token)
  end

  def number
    payload.pull_request_number
  end

  def repo_name
    payload.full_repo_name
  end
end
