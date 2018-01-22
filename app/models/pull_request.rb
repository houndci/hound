# frozen_string_literal: true
class PullRequest
  FILE_REMOVED_STATUS = "removed"
  COMMENT_LINE_DELIMITER = "<br>"

  pattr_initialize :payload, :token

  def comments
    @comments ||= user_github.pull_request_comments(repo_name, number)
  end

  def commit_files
    @commit_files ||= modified_commit_files
  end

  def make_comments(violations, errors)
    comments = violations.map { |violation| build_comment(violation) }
    hound_github.create_pull_request_review(
      repo_name,
      number,
      comments,
      ReviewBody.new(errors).to_s,
    )
  end

  def opened?
    payload.action == "opened"
  end

  def synchronize?
    payload.action == "synchronize"
  end

  def head_commit
    @head_commit ||= Commit.new(repo_name, payload.head_sha, user_github)
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
    github_files = user_github.pull_request_files(repo_name, number)

    github_files.select do |github_file|
      github_file.status != FILE_REMOVED_STATUS
    end
  end

  def build_comment(violation)
    {
      path: violation.filename,
      position: violation.patch_position,
      body: violation.messages.join(COMMENT_LINE_DELIMITER),
    }
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

  def repo_name
    payload.full_repo_name
  end
end
