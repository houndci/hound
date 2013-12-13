require 'octokit'
require 'base64'

class GithubApi
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

  def create_pending_status(full_repo_name, sha, description)
    client.create_status(full_repo_name, sha, 'pending', description: description)
  end

  def create_successful_status(full_repo_name, sha, description)
    client.create_status(full_repo_name, sha, 'success', description: description)
  end

  def create_failure_status(full_repo_name, sha, description, target_url)
    client.create_status(full_repo_name, sha, 'failure', description: description, target_url: target_url)
  end

  def pull_request_files(pull_request)
    files = client.pull_request_files(pull_request.full_repo_name, pull_request.number)
    files.map do |file|
      contents = client.contents(pull_request.full_repo_name, path: file.filename, ref: pull_request.head_sha)
      Base64.decode64(contents.content)
    end
  end

  private

  def user_repos
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

  def org_repos
    repos = []

    orgs.each do |org|
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

  def orgs
    client.orgs
  end
end
