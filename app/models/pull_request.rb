class PullRequest
  CONFIG_FILE = '.hound.yml'

  def initialize(payload, github_token)
    @payload = payload
    @github_token = github_token
  end

  def head_includes?(line)
    head_commit_files.detect { |file| file.modified_lines.include?(line) }
  end

  def comments
    api.pull_request_comments(full_repo_name, number)
  end

  def pull_request_files
    api.pull_request_files(full_repo_name, number).map do |file|
      build_commit_file(file)
    end
  end

  def add_comment(violation)
    github = GithubApi.new(ENV['HOUND_GITHUB_TOKEN'])
    github.add_comment(
      pull_request_number: number,
      comment: violation.messages.join("<br>"),
      commit: head_commit,
      filename: violation.filename,
      patch_position: violation.line.patch_position
    )
  end

  def config
    head_commit.file_content(CONFIG_FILE)
  end

  def opened?
    @payload.action == 'opened'
  end

  def synchronize?
    @payload.action == 'synchronize'
  end

  private

  def head_commit_files
    head_commit.files
  end

  def build_commit_file(file)
    CommitFile.new(file, head_commit)
  end

  def api
    @api ||= GithubApi.new(@github_token)
  end

  def number
    @payload.number
  end

  def full_repo_name
    @payload.full_repo_name
  end

  def head_commit
    @head_commit ||= Commit.new(full_repo_name, @payload.head_sha, api)
  end
end
