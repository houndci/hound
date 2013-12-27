class PullRequest
  # does this belong in build runner?
  ALLOWED_PULL_REQUEST_ACTIONS = %w[opened synchronize]

  def initialize(attributes)
    @attributes = attributes
  end

  def valid?
    @attributes.present? && valid_action? && repo
  end

  def files
    pull_request_files.map do |pull_request_file|
      ModifiedFile.new(pull_request_file, self, api)
    end
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

  def repo
    @repo ||= Repo.active.where(github_id: github_repo_id).first
  end

  def head_sha
    @attributes['pull_request']['head']['sha']
  end

  def full_repo_name
    @attributes['repository']['full_name']
  end

  private

  def set_status(status, options)
    api.create_status(full_repo_name, head_sha, status, options)
  end

  def pull_request_files
    api.pull_request_files(full_repo_name, number)
  end

  def api
    @api ||= GithubApi.new(repo.github_token)
  end

  def valid_action?
    ALLOWED_PULL_REQUEST_ACTIONS.include?(action)
  end

  def github_repo_id
    @attributes['repository']['id']
  end

  def number
    @attributes['number']
  end

  def action
    @attributes['action']
  end
end
