class PullRequest
  def initialize(payload, github_token)
    @payload = payload
    @github_token = github_token
  end

  def files
    api.pull_request_files(full_repo_name, number).
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
    api.file_contents(full_repo_name, filename, head_sha)
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

  def add_failure_comment(target_url)
    hound_github_client = Octokit::Client.new(access_token: ENV['HOUND_GITHUB_TOKEN'])
    failure_comment = "Hound does not approve - [details](#{target_url})"
    hound_github_client.add_comment(full_repo_name, number, failure_comment)
  end

  private

  def set_status(status, options)
    api.create_status(
      full_repo_name,
      head_sha,
      status,
      options
    )
  end

  def api
    @api ||= GithubApi.new(@github_token)
  end
end
