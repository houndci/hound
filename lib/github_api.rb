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

  def add_hound_to_repo(full_repo_name)
    repo = client.repository(full_repo_name)
    organization = repo.organization

    if organization
      repo_teams = client.repository_teams(full_repo_name)
      client.add_team_member(repo_teams.first.id, hound_username)
    else
      client.add_collaborator(full_repo_name, hound_username)
    end
  end

  def add_comment(options)
    client.create_pull_request_comment(
      options[:repo_name],
      options[:pull_request_number],
      options[:comment],
      options[:commit],
      options[:filename],
      options[:line_number]
    )
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

  def commit_files(full_repo_name, commit_sha)
    commit = client.commit(full_repo_name, commit_sha)
    commit.files
  end

  def pull_request_files(full_repo_name, number)
    client.pull_request_files(full_repo_name, number)
  end

  def file_contents(full_repo_name, filename, sha)
    client.contents(full_repo_name, path: filename, ref: sha)
  end

  private

  def user_repos
    repos = []
    page = 1

    loop do
      results = client.repos(nil, page: page)
      repos.concat(authorized_repos(results))
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
        repos.concat(authorized_repos(results))
        break unless results.any?
        page += 1
      end
    end

    repos
  end

  def orgs
    client.orgs
  end

  def authorized_repos(repos)
    repos.select {|repo| repo.permissions.admin }
  end

  def hound_username
    ENV['HOUND_GITHUB_USERNAME']
  end
end
