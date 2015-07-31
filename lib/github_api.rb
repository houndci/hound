require "attr_extras"
require "octokit"
require "base64"

class GithubApi
  ORGANIZATION_TYPE = "Organization"
  PREVIEW_MEDIA_TYPE = "application/vnd.github.moondragon+json"

  attr_reader :file_cache, :token

  def initialize(token)
    @token = token
    @file_cache = {}
  end

  def client
    @client ||= Octokit::Client.new(access_token: token, auto_paginate: true)
  end

  def scopes
    client.scopes(token).join(",")
  end

  def repos
    all_repos = client.repos(nil, accept: PREVIEW_MEDIA_TYPE)
    authorized_repos(all_repos)
  end

  def repo(repo_name)
    client.repository(repo_name)
  end

  def add_pull_request_comment(options)
    client.create_pull_request_comment(
      options[:commit].repo_name,
      options[:pull_request_number],
      options[:comment],
      options[:commit].sha,
      options[:filename],
      options[:patch_position]
    )
  end

  def create_hook(full_repo_name, callback_endpoint)
    hook = client.create_hook(
      full_repo_name,
      "web",
      { url: callback_endpoint },
      { events: ["pull_request"], active: true }
    )

    if block_given?
      yield hook
    else
      hook
    end
  rescue Octokit::UnprocessableEntity => error
    if error.message.include? "Hook already exists"
      true
    else
      raise
    end
  end

  def remove_hook(full_github_name, hook_id)
    response = client.remove_hook(full_github_name, hook_id)

    if block_given?
      yield
    else
      response
    end
  end

  def pull_request_comments(full_repo_name, pull_request_number)
    client.pull_request_comments(full_repo_name, pull_request_number)
  end

  def pull_request_files(full_repo_name, number)
    client.pull_request_files(full_repo_name, number)
  end

  def file_contents(full_repo_name, filename, sha)
    file_cache["#{full_repo_name}/#{sha}/#{filename}"] ||=
      client.contents(full_repo_name, path: filename, ref: sha)
  end

  def accept_pending_invitations
    pending_memberships = client.organization_memberships(state: "pending")
    pending_memberships.each do |pending_membership|
      client.update_organization_membership(
        pending_membership["organization"]["login"],
        state: "active"
      )
    end
  end

  def create_pending_status(full_repo_name, sha, description)
    create_status(
      repo: full_repo_name,
      sha: sha,
      state: "pending",
      description: description
    )
  end

  def create_success_status(full_repo_name, sha, description)
    create_status(
      repo: full_repo_name,
      sha: sha,
      state: "success",
      description: description
    )
  end

  def create_error_status(full_repo_name, sha, description, target_url = nil)
    create_status(
      repo: full_repo_name,
      sha: sha,
      state: "error",
      description: description,
      target_url: target_url
    )
  end

  def add_collaborator(repo_name, username)
    client.add_collaborator(repo_name, username)
  end

  def remove_collaborator(repo_name, username)
    client.remove_collaborator(repo_name, username)
  end

  def user_teams
    client.user_teams
  end

  def repo_teams(repo_name)
    client.repository_teams(repo_name)
  end

  def org_teams(org_name)
    client.org_teams(org_name)
  end

  def team_repos(team_id)
    client.team_repos(team_id)
  end

  def create_team(team_name:, org_name:, repo_name:)
    team_options = {
      name: team_name,
      repo_names: [repo_name],
      permission: "push"
    }
    client.create_team(org_name, team_options)
  end

  def add_repo_to_team(team_id, repo_name)
    client.add_team_repository(team_id, repo_name)
  end

  def remove_repo_from_team(team_id, repo_name)
    client.remove_team_repository(team_id, repo_name)
  end

  def add_user_to_team(team_id, username)
    client.add_team_membership(team_id, username)
  end

  def remove_user_from_team(team_id, username)
    client.remove_team_membership(team_id, username)
  end

  def update_team(team_id, options)
    client.update_team(team_id, options)
  end

  private

  def authorized_repos(repos)
    repos.select { |repo| repo.permissions.admin }
  end

  def create_status(repo:, sha:, state:, description:, target_url: nil)
    client.create_status(
      repo,
      sha,
      state,
      context: "hound",
      description: description,
      target_url: target_url
    )
  rescue Octokit::NotFound
    # noop
  end
end
