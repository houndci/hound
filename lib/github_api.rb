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

  def create_status(full_repo_name, commit_hash, status, description)
    client.create_status(
      full_repo_name,
      commit_hash,
      status,
      description: description
    )
  end
end
