class PullRequest
  CONFIG_FILE = '.hound.yml'

  def initialize(payload, github_token)
    @payload = payload
    @github_token = github_token
  end

  def files
    api.pull_request_files(@payload.full_repo_name, @payload.number).
      map { |file| ModifiedFile.new(file, self) }
  end

  def set_pending_status
    set_status(:pending, description: 'Hound is working...')
  end

  def set_success_status
    set_status(:success, description: 'Hound approves')
  end

  def set_failure_status(target_url)
    message = 'Hound does not approve'
    set_status(:failure, description: message, target_url: target_url)
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

  def set_status(status, options)
    api.create_status(
      @payload.full_repo_name,
      @payload.head_sha,
      status,
      options
    )
  end

  def api
    @api ||= GithubApi.new(@github_token)
  end
end
