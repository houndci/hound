class PullRequest
  def initialize(payload)
    @payload = JSON.parse(payload)
  end

  def allowed?
    valid_payload? && allowed_action?
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

  def repo_owner
    @payload['repository']['owner']['login']
  end

  private

  def valid_payload?
    @payload && @payload['pull_request']
  end

  def allowed_action?
    allowed_actions = %w(opened synchronize)
    allowed_actions.include?(@payload['action'])
  end
end
