class PullRequest
  CONFIG_FILE = '.hound.yml'

  def initialize(payload, github_token)
    @payload = payload
    @github_token = github_token
  end

  def files
    api.pull_request_files(full_repo_name, number).map do |file|
      ModifiedFile.new(file, self)
    end
  end

  def file_contents(filename)
    api.file_contents(full_repo_name, filename, head_sha)
  end

  def add_comment(filename, diff_position, message)
    github = GithubApi.new(ENV['HOUND_GITHUB_TOKEN'])
    github.add_comment(
      repo_name: full_repo_name,
      pull_request_number: number,
      comment: message,
      commit: head_sha,
      filename: filename,
      line_number: diff_position
    )
  end

  def file_contents(filename)
    file_contents = api
      .file_contents(@payload.full_repo_name, filename, @payload.head_sha)
    Base64.decode64(file_contents.content)
  end

  def config
    file_contents(CONFIG_FILE)
  rescue Octokit::NotFound
    nil
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
