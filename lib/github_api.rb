require 'octokit'

class GithubApi
  attr_reader :client

  def initialize(token)
    @client = Octokit::Client.new(oauth_token: token)
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

  def create_pending_status(commit, description)
    client.create_status(
      commit.full_repo_name,
      commit.id,
      'pending',
      description: description
    )
  end

  def create_successful_status(commit, description)
    client.create_status(
      commit.full_repo_name,
      commit.id,
      'success',
      description: description
    )
  end

  def create_failure_status(commit, description)
    client.create_status(
      commit.full_repo_name,
      commit.id,
      'failure',
      description: description
    )
  end

  def patch(commit)
    client.compare(commit.full_repo_name, commit.previous_commit_id, commit.id).files.first.patch
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
