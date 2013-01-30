class PullRequest
  attr_reader :payload

  def initialize(payload)
    @payload = JSON.parse(payload)
  end

  def full_repo_name
    payload['pull_request']['head']['repo']['full_name']
  end

  def sha
    payload['pull_request']['head']['sha']
  end

  def github_login
    payload['pull_request']['head']['user']['login']
  end
end
