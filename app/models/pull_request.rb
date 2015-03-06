class PullRequest
  pattr_initialize :payload

  def comments
    @comments ||= github.pull_request_comments(full_repo_name, number)
  end

  def pull_request_files
    @pull_request_files ||= github.
      pull_request_files(full_repo_name, number).
      map { |file| build_commit_file(file) }
  end

  def comment_on_violation(violation)
    private_github.add_pull_request_comment(
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
    @head_commit ||= Commit.new(full_repo_name, payload.head_sha, github)
  end

  private

  def build_commit_file(file)
    CommitFile.new(file, head_commit)
  end

  def github
    @github ||= GithubApi.new(github_token)
  end

  def private_github
    @private_github ||= GithubApi.new(ENV["PRIVATE_GITHUB_TOKEN"])
  end

  def number
    payload.pull_request_number
  end

  def full_repo_name
    payload.full_repo_name
  end

  def github_token
    if payload.private_repo?
      ENV["PRIVATE_GITHUB_TOKEN"]
    else
      ENV["PUBLIC_GITHUB_TOKEN"]
    end
  end
end
