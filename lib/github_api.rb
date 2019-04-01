# frozen_string_literal: true
require "attr_extras"
require "octokit"
require "base64"

class GitHubApi
  ORGANIZATION_TYPE = "Organization"
  PREVIEW_HEADER = "application/vnd.github.machine-man-preview+json"

  attr_reader :file_cache, :token

  def initialize(token)
    @token = token
    @file_cache = {}
  end

  def user_installations
    client.find_user_installations(preview_options)[:installations]
  end

  def create_installation_token(installation_id)
    response = client.create_app_installation_access_token(
      installation_id,
      preview_options,
    )
    response[:token]
  end

  def installation_repos
    client.list_app_installation_repositories(preview_options)[:repositories]
  end

  def accounts_for_plan(plan_id)
    client.list_accounts_for_plan(plan_id)
  rescue Octokit::NotFound => error
    Raven.capture_exception(error)
    []
  end

  def repos
    client.repos
  end

  def repo(repo_name)
    client.repository(repo_name)
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

  def create_pull_request_review(repo_name, pr_number, comments, body)
    client.post(
      "#{Octokit::Repository.path(repo_name)}/pulls/#{pr_number}/reviews",
      event: "COMMENT",
      body: body,
      comments: comments,
    )
  end

  def pull_request_files(full_repo_name, number)
    client.pull_request_files(full_repo_name, number)
  end

  def file_contents(full_repo_name, filename, sha)
    file_cache["#{full_repo_name}/#{sha}/#{filename}"] ||=
      client.contents(full_repo_name, path: filename, ref: sha)
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

  def accept_invitation(repo_name)
    repo_invitation = find_invitation_for_repo(repo_name)

    if repo_invitation
      accept_repository_invitation(repo_invitation)
    else
      raise "Invitation for Hound to #{repo_name} not found"
    end
  end

  def add_collaborator(repo_name, username)
    client.add_collaborator(repo_name, username)
  end

  def remove_collaborator(repo_name, username)
    client.remove_collaborator(repo_name, username)
  end

  def repository?(repo_name)
    client.repository?(repo_name)
  rescue Octokit::Unauthorized
    false
  end

  private

  def client
    @_client ||= Octokit::Client.new(bearer_token: token, auto_paginate: true)
  end

  def create_status(repo:, sha:, state:, description:, target_url: nil)
    client.create_status(
      repo,
      sha,
      state,
      context: "Hound",
      description: description,
      target_url: target_url
    )
  end

  def find_invitation_for_repo(repo_name)
    invitations = client.user_repository_invitations(
      accept: "application/vnd.github.swamp-thing-preview",
    )
    invitations.detect do |invitation|
      invitation.repository.full_name == repo_name
    end
  end

  def accept_repository_invitation(invitation)
    response = client.accept_repository_invitation(
      invitation.id,
      accept: "application/vnd.github.swamp-thing-preview",
    )
    response == ""
  end

  def preview_options
    { accept: PREVIEW_HEADER }
  end
end
