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

  def add_comment(file, line_number)
    github = GithubApi.new(ENV['HOUND_GITHUB_TOKEN'])
    comment = 'Hound has an issue with this code'
    github.add_comment(full_repo_name, number, comment, head_sha, file, line_number)
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
