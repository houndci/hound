class PullRequest
  pattr_initialize :payload, :token

  FILE_REMOVED_STATUS = "removed"

  def comments
    @comments ||= user_github.pull_request_comments(full_repo_name, number)
  end

  def pull_request_files
    @pull_request_files ||= user_github.
      pull_request_files(full_repo_name, number).
      reject { |github_file| file_removed?(github_file) }.
      map { |github_file| build_pull_request_file(github_file) }
  end

  def comment_on_violation(violation)
    hound_github.add_pull_request_comment(
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
    @head_commit ||= Commit.new(full_repo_name, payload.head_sha, user_github)
  end

  private

  def build_pull_request_file(github_file)
    PullRequestFile.new(
      github_file.filename,
      -> { head_commit.file_content(github_file.filename) },
      github_file.patch,
    )
  end

  def file_removed?(github_file)
    github_file.status == FILE_REMOVED_STATUS
  end

  def user_github
    @user_github ||= GithubApi.new(token)
  end

  def hound_github
    @hound_github ||= GithubApi.new(ENV["HOUND_GITHUB_TOKEN"])
  end

  def number
    payload.pull_request_number
  end

  def full_repo_name
    payload.full_repo_name
  end
end
