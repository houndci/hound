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

  def create_pending_status(pull_request, description)
    client.create_status(
      pull_request.full_repo_name,
      pull_request.sha,
      'pending',
      description: description
    )
  end
end
