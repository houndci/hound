class Payload
  ALLOWED_ACTIONS = %w[opened synchronize]

  def initialize(payload_data)
    @payload_data = payload_data
  end

  def head_sha
    @payload_data['pull_request']['head']['sha']
  end

  def github_repo_id
    @payload_data['repository']['id']
  end

  def full_repo_name
    @payload_data['repository']['full_name']
  end

  def number
    @payload_data['number']
  end

  def valid_action?
    ALLOWED_ACTIONS.include?(action)
  end

  private

  def action
    @payload_data['action']
  end
end
