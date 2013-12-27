require 'octokit'
require 'base64'

class GithubApi
  STATUSES = [:success, :pending, :failure]

  attr_reader :client

  def initialize(token)
    @client = Octokit::Client.new(access_token: token)
  end

  def repos
    user_repos + org_repos
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

  def pull_request_files(full_repo_name, number)
    client.pull_request_files(full_repo_name, number)
  end

  def file_contents(full_repo_name, filename, sha)
    client.contents(full_repo_name, path: filename, ref: sha)
  end

  def create_status(full_repo_name, sha, status, options)
    if STATUSES.include?(status.to_sym)
      client.create_status(full_repo_name, sha, status, options)
    else
      raise ArgumentError.new("Status must be one of these: #{STATUSES}")
    end
  end

  private

  def user_repos
    repos = []
    page = 1

    loop do
      results = client.repos(nil, page: page)
      repos.concat filter_unauthorized_repos(results)
      break unless results.any?
      page += 1
    end

    repos
  end

  def org_repos
    repos = []

    orgs.each do |org|
      page = 1

      loop do
        results = client.org_repos(org[:login], page: page)
        repos.concat filter_unauthorized_repos(results)
        break unless results.any?
        page += 1
      end
    end

    repos
  end

  def orgs
    client.orgs
  end

  def filter_unauthorized_repos(repos)
    repos.select {|repo| repo.permissions.admin }
  end
end
