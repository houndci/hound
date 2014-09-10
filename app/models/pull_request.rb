class PullRequest
  pattr_initialize :payload, :github_token

  def head_includes?(line)
    head_commit_files.detect { |file| file.modified_lines.include?(line) }
  end

  def comments
    @comments ||= api.pull_request_comments(full_repo_name, number)
  end

  def pull_request_files
    @pull_request_files ||= api.
      pull_request_files(full_repo_name, number).
      map { |file| build_commit_file(file) }
  end

  def add_comment(violation)
    api.add_comment(
      pull_request_number: number,
      comment: violation.messages.join("<br>"),
      commit: head_commit,
      filename: violation.filename,
      patch_position: violation.line.patch_position
    )
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

  def head_commit_files
    head_commit.files
  end

  def build_commit_file(file)
    CommitFile.new(file, head_commit)
  end

  def api
    @api ||= GithubApi.new(github_token)
  end

  def number
    payload.number
  end

  def full_repo_name
    payload.full_repo_name
  end
end
