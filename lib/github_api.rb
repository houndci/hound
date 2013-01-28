require 'octokit'

class GithubApi
  attr_reader :token

  def initialize(token)
    @token = token
  end

  def get_repos
    client = Octokit::Client.new(oauth_token: token)
    client.repos
  end

  def create_pull_request_hook(full_repo_name, callback_endpoint)
    client = Octokit::Client.new(oauth_token: token)
    client.create_hook(
      full_repo_name,
      'web',
      { url: callback_endpoint },
      { events: ['pull_request'], active: true }
    )
  end
end
