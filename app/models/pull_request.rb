class PullRequest
  CONFIG_FILE = '.hound.yml'
  SUCCESS_MESSAGE = 'No style issues found! :+1:'

  def initialize(payload, github_token)
    @payload = payload
    @github_token = github_token
  end

  def head_includes?(line)
    head_commit_files.detect do |file|
      file.modified_lines.include?(line)
    end
  end

  def head_commit_files
    api.commit_files(full_repo_name, head_sha).map do |file|
      ModifiedFile.new(file, self)
    end
  end

  def pull_request_files
    api.pull_request_files(full_repo_name, number).map do |file|
      ModifiedFile.new(file, self)
    end
  end

  def file_contents(filename)
    api.file_contents(full_repo_name, filename, head_sha)
  end

  def add_comment(filename, patch_position, message)
    github = GithubApi.new(ENV['HOUND_GITHUB_TOKEN'])
    github.add_comment(
      repo_name: full_repo_name,
      pull_request_number: number,
      comment: message,
      commit: head_sha,
      filename: filename,
      line_number: patch_position
    )
  end

  def file_contents(filename)
    file_contents = api
      .file_contents(full_repo_name, filename, head_sha)
    Base64.decode64(file_contents.content)
  end

  def config
    file_contents(CONFIG_FILE)
  rescue Octokit::NotFound
    nil
  end

  def config_hash
    config ? YAML.load(config) : {}
  end

  def opened?
    @payload.action == 'opened'
  end

  def synchronize?
    @payload.action == 'synchronize'
  end

  private

  def api
    @api ||= GithubApi.new(@github_token)
  end

  def full_repo_name
    @payload.full_repo_name
  end

  def number
    @payload.number
  end

  def head_sha
    @payload.head_sha
  end
end
