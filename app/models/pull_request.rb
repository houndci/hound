# frozen_string_literal: true
class PullRequest
  FILE_REMOVED_STATUS = "removed"
  COMMENT_LINE_DELIMITER = "<br>"

  pattr_initialize :payload, :token

  def comments
    @comments ||= user_github.pull_request_comments(full_repo_name, number)
  end

  def commit_files
    @commit_files ||= modified_commit_files
  end

  def comment_on_violation(violation)
    hound_github.add_pull_request_comment(
      pull_request_number: number,
      comment: violation.messages.join(COMMENT_LINE_DELIMITER),
      commit: head_commit,
      filename: violation.filename,
      patch_position: violation.patch_position
    )
  end

  def delete_comment(comment)
    hound_github.delete_pull_request_comment(full_repo_name, comment.id)
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
    github_files = user_github.pull_request_files(full_repo_name, number)

    github_files.select do |github_file|
      github_file.status != FILE_REMOVED_STATUS
    end
  end

  def user_github
    @user_github ||= GithubApi.new(token)
  end

  def hound_github
    @hound_github ||= GithubApi.new(Hound::GITHUB_TOKEN)
  end

  def number
    payload.pull_request_number
  end

  def full_repo_name
    payload.full_repo_name
  end
end
