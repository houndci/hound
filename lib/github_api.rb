require "octokit"
require "base64"
require "active_support/core_ext/object/with_options"

class GithubApi
  SERVICES_TEAM_NAME = "Services"
  PREVIEW_MEDIA_TYPE =
    ::Octokit::Client::Organizations::ORG_INVITATIONS_PREVIEW_MEDIA_TYPE

  pattr_initialize :token

  def client
    @client ||= Octokit::Client.new(access_token: token, auto_paginate: true)
  end

  def repos
    user_repos + org_repos
  end

  def add_user_to_repo(username, repo_name)
    repo = repo(repo_name)

    if repo.organization
      add_user_to_org(username, repo)
    else
      client.add_collaborator(repo.full_name, username)
    end
  end

  def repo(repo_name)
    client.repository(repo_name)
  end

  def add_comment(options)
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
    paginate do |page|
      client.pull_request_comments(
        full_repo_name,
        pull_request_number,
        page: page
      )
    end
  end

  def pull_request_files(full_repo_name, number)
    client.pull_request_files(full_repo_name, number)
  end

  def file_contents(full_repo_name, filename, sha)
    client.contents(full_repo_name, path: filename, ref: sha)
  end

  def user_teams
    client.user_teams
  end

  def accept_pending_invitations
    with_preview_client do |preview_client|
      pending_memberships =
        preview_client.organization_memberships(state: "pending")
      pending_memberships.each do |pending_membership|
        preview_client.update_organization_membership(
          pending_membership["organization"]["login"],
          state: "active"
        )
      end
    end
  end

  private

  def add_user_to_org(username, repo)
    repo_teams = client.repository_teams(repo.full_name)
    admin_team = admin_access_team(repo_teams)

    if admin_team
      add_user_to_team(username, admin_team.id)
    else
      add_user_and_repo_to_services_team(username, repo)
    end
  end

  def admin_access_team(repo_teams)
    token_bearer = GithubUser.new(self)

    repo_teams.detect do |repo_team|
      token_bearer.has_admin_access_through_team?(repo_team.id)
    end
  end

  def add_user_and_repo_to_services_team(username, repo)
    team = find_team(SERVICES_TEAM_NAME, repo)

    if team
      client.add_team_repository(team.id, repo.full_name)
    else
      team = create_team(SERVICES_TEAM_NAME, repo)
    end

    add_user_to_team(username, team.id)
  end

  def add_user_to_team(username, team_id)
    with_preview_client do |preview_client|
      preview_client.add_team_membership(team_id, username)
    end
  rescue Octokit::NotFound
    false
  end

  def find_team(name, repo)
    client.org_teams(repo.organization.login).detect do |team|
      team.name == name
    end
  end

  def create_team(name, repo)
    team_options = {
      name: name,
      repo_names: [repo.full_name],
      permission: "pull"
    }
    client.create_team(repo.organization.login, team_options)
  rescue Octokit::UnprocessableEntity => e
    if team_exists_exception?(e)
      find_team(name, repo)
    else
      raise
    end
  end

  def user_repos
    repos = paginate { |page| client.repos(nil, page: page) }
    authorized_repos(repos)
  end

  def org_repos
    repos = orgs.flat_map do |org|
      paginate { |page| client.org_repos(org[:login], page: page) }
    end

    authorized_repos(repos)
  end

  def paginate
    page = 1
    results = []
    all_pages_fetched = false

    until all_pages_fetched do
      page_results = yield(page)

      if page_results.empty?
        all_pages_fetched = true
      else
        results += page_results
        page += 1
      end
    end

    results
  end

  def orgs
    client.orgs
  end

  def authorized_repos(repos)
    repos.select { |repo| repo.permissions.admin }
  end

  def team_exists_exception?(exception)
    exception.errors.any? do |error|
      error[:field] == "name" && error[:code] == "already_exists"
    end
  end

  def with_preview_client(&block)
    client.with_options(accept: PREVIEW_MEDIA_TYPE, &block)
  end
end
