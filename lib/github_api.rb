require 'octokit'

class GithubApi
  attr_reader :client

  def initialize(token)
    @client = Octokit::Client.new(oauth_token: token)
  end

  def get_repos
    repos = []
    repos.concat get_user_repos
    repos.concat get_org_repos
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

  private

  def get_user_repos
    repos = []
    page = 1

    loop do
      results = client.repos(nil, page: page)
      repos.concat results
      break unless results.any?
      page += 1
    end

    repos
  end

  def get_org_repos
    repos = []

    get_orgs.each do |org|
      page = 1

      loop do
        results = client.org_repos(org[:login], page: page)
        repos.concat results
        break unless results.any?
        page += 1
      end
    end

    repos
  end

  def get_orgs
    client.orgs
  end
end
