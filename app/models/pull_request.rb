class PullRequest
  pattr_initialize :payload

  def comments
    @comments ||= api.pull_request_comments(full_repo_name, number)
  end

  def pull_request_files
    @pull_request_files ||= api.
      pull_request_files(full_repo_name, number).
      map { |github_file| build_pull_request_file(github_file) }.compact
  end

  def comment_on_violation(violation)
    api.add_pull_request_comment(
      pull_request_number: number,
      comment: violation.messages.join("<br>"),
      commit: head_commit,
      filename: violation.filename,
      patch_position: violation.patch_position
    )
  end

  def repository_owner_name
    payload.repository_owner_name
  end

  def opened?
    payload.action == "opened"
  end

  def synchronize?
    payload.action == "synchronize"
  end

  def head_commit
    @head_commit ||= Commit.new(full_repo_name, payload.head_sha, api)
  end

  private

  def build_pull_request_file(github_file)
    unless file_removed?(github_file)
      PullRequestFile.new(
        github_file.filename,
        github_file.patch,
        head_commit.file_content(github_file.filename)
      )
    end
  end

  def file_removed?(github_file)
    github_file.status == "removed"
  end

  def api
    @api ||= GithubApi.new(ENV["HOUND_GITHUB_TOKEN"])
  end

  def number
    payload.pull_request_number
  end

  def full_repo_name
    payload.full_repo_name
  end
end
