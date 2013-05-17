class PullRequest
  def initialize(payload)
    @payload = JSON.parse(payload)
  end

  def valid?
    @payload && @payload['pull_request'].present?
  end

  def full_repo_name
    @payload['repository']['full_name']
  end

  def head_sha
    @payload['pull_request']['head']['sha']
  end

  def number
    @payload['number']
  end

  def github_repo_id
    @payload['repository']['id']
  end

  def action
    @payload['action']
  end
end
