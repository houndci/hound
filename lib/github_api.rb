require 'octokit'

class GithubApi
  attr_reader :client

  def initialize(token)
    @client = Octokit::Client.new(oauth_token: token)
  end

  def get_repos
    client.repos
  end

  def create_pull_request_hook(full_repo_name, callback_endpoint)
    client.create_hook(
      full_repo_name,
      'web',
      { url: callback_endpoint },
      { events: ['pull_request'], active: true }
    )
  end

  def remove_pull_request_hook(full_github_name, hook_id)
    client.remove_hook(full_github_name, hook_id)
  end

  def create_pending_status(pull_request, description)
    client.create_status(
      pull_request.full_repo_name,
      pull_request.sha,
      'pending',
      description: description
    )
  end

  def create_successful_status(pull_request, description)
    client.create_status(
      pull_request.full_repo_name,
      pull_request.sha,
      'success',
      description: description
    )
  end

  def create_failure_status(pull_request, description)
    client.create_status(
      pull_request.full_repo_name,
      pull_request.sha,
      'failure',
      description: description
    )
  end
end
