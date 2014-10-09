module GithubApiHelper
  def stub_add_collaborator_request(full_repo_name)
    url = "https://api.github.com/repos/#{full_repo_name}/collaborators/houndci"
    stub_request(:put, url).
      with(headers: { 'Authorization' => "token #{auth_token}" }).
      to_return(status: 204)
  end

  def stub_repo_requests(auth_token)
    stub_paginated_repo_requests(auth_token)
    stub_orgs_request(auth_token)
    stub_paginated_org_repo_requests(auth_token)
  end

  def stub_repo_request(repo_name, token = auth_token)
    stub_request(
      :get,
      "https://api.github.com/repos/#{repo_name}"
    ).with(
      headers: { 'Authorization' => "token #{token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/repo.json').
        gsub('testing/repo', repo_name),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_repo_with_org_request(repo_name, token = auth_token)
    stub_request(
      :get,
      "https://api.github.com/repos/#{repo_name}"
    ).with(
      headers: { 'Authorization' => "token #{token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/repo_with_org.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_team_creation_request(org, repo_name, token)
    stub_request(
      :post,
      "https://api.github.com/orgs/#{org}/teams"
    ).with(
      body: {
        name: 'Services',
        repo_names: [repo_name],
        permission: 'pull'
      }.to_json,
      headers: { 'Authorization' => "token #{token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/team_creation.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_failed_team_creation_request(org, repo_name, token)
    stub_request(
      :post,
      "https://api.github.com/orgs/#{org}/teams"
    ).with(
      body: {
        name: 'Services',
        repo_names: [repo_name],
        permission: 'pull'
      }.to_json,
      headers: { 'Authorization' => "token #{token}" }
    ).to_return(
      status: 422,
      body: File.read('spec/support/fixtures/failed_team_creation.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_repo_teams_request(repo_name, token = auth_token)
    stub_request(
      :get,
      "https://api.github.com/repos/#{repo_name}/teams"
    ).with(
      headers: { 'Authorization' => "token #{token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/repo_teams.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_user_teams_request(token = auth_token)
    stub_request(
      :get,
      'https://api.github.com/user/teams'
    ).with(
      headers: { 'Authorization' => "token #{token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/user_teams.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_empty_repo_teams_request(repo_name, token)
    stub_request(
      :get,
      "https://api.github.com/repos/#{repo_name}/teams"
    ).with(
      headers: { 'Authorization' => "token #{token}" }
    ).to_return(
      status: 200,
      body: '[]',
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_org_teams_request(org_name, token)
    stub_request(
      :get,
      "https://api.github.com/orgs/#{org_name}/teams"
    ).with(
      headers: { 'Authorization' => "token #{token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/repo_teams.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_add_repo_to_team_request(repo_name, team_id, token = auth_token)
    stub_request(
      :put,
      "https://api.github.com/teams/#{team_id}/repos/#{repo_name}"
    ).with(
      headers: { 'Authorization' => "token #{token}" }
    ).to_return(
      status: 204
    )
  end

  def stub_org_teams_with_services_request(org_name, token)
    json_response = File.read(
      'spec/support/fixtures/org_teams_with_services_team.json'
    )
    stub_request(
      :get,
      "https://api.github.com/orgs/#{org_name}/teams"
    ).with(
      headers: { 'Authorization' => "token #{token}" }
    ).to_return(
      status: 200,
      body: json_response,
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_chained_org_teams_request(org_name, token)
    no_services_team_json_response =
      File.read("spec/support/fixtures/repo_teams.json")
    services_team_json_response =
      File.read("spec/support/fixtures/org_teams_with_services_team.json")
    stub_request(
      :get,
      "https://api.github.com/orgs/#{org_name}/teams"
    ).with(
      headers: { "Authorization" => "token #{token}" }
    ).to_return(
      status: 200,
      body: no_services_team_json_response,
      headers: { "Content-Type" => "application/json; charset=utf-8" }
    ).then.to_return(
      status: 200,
      body: services_team_json_response,
      headers: { "Content-Type" => "application/json; charset=utf-8" }
    )
  end

  def stub_add_user_to_team_request(username, team_id, token = auth_token)
    stub_request(
      :put,
      "https://api.github.com/teams/#{team_id}/memberships/#{username}"
    ).with(
      headers: {
        "Authorization" => "token #{token}",
        "Accept" => "application/vnd.github.the-wasp-preview+json"
      }
    ).to_return(
      status: 200
    )
  end

  def stub_failed_add_user_to_team_request(username, team_id, token)
    stub_request(
      :put,
      "https://api.github.com/teams/#{team_id}/memberships/#{username}"
    ).with(
      headers: {
        "Authorization" => "token #{token}",
        "Accept" => "application/vnd.github.the-wasp-preview+json"
      }
    ).to_return(
      status: 404
    )
  end

  def stub_add_user_to_repo_request(username, repo_name, token)
    stub_request(
      :put,
      "https://api.github.com/repos/#{repo_name}/collaborators/#{username}"
    ).with(
      body: '{}',
      headers: { 'Authorization' => "token #{token}" }
    ).to_return(
      status: 204,
    )
  end

  def stub_hook_creation_request(full_repo_name, callback_endpoint)
    stub_request(
      :post,
      "https://api.github.com/repos/#{full_repo_name}/hooks"
    ).with(
      body: %({"name":"web","config":{"url":"#{callback_endpoint}"},"events":["pull_request"],"active":true}),
      headers: { 'Authorization' => "token #{auth_token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/github_hook_creation_response.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_failed_hook_creation_request(full_repo_name, callback_endpoint)
    stub_request(
      :post,
      "https://api.github.com/repos/#{full_repo_name}/hooks"
    ).with(
      body: %({"name":"web","config":{"url":"#{callback_endpoint}"},"events":["pull_request"],"active":true}),
      headers: { 'Authorization' => "token #{auth_token}" }
    ).to_return(
      status: 422,
      body: File.read('spec/support/fixtures/failed_hook.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_hook_removal_request(full_repo_name, hook_id)
    url = "https://api.github.com/repos/#{full_repo_name}/hooks/#{hook_id}"
    stub_request(:delete, url).
      with(headers: { 'Authorization' => /^token \w+$/ }).
      to_return(status: 204)
  end

  def stub_commit_request(full_repo_name, commit_sha, auth_token = 'githubtoken')
    stub_request(
      :get,
      "https://api.github.com/repos/#{full_repo_name}/commits/#{commit_sha}"
    ).with(
      headers: { 'Authorization' => "token #{auth_token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/commit.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_pull_request_files_request(full_repo_name, pull_request_number, auth_token = 'githubtoken')
    stub_request(
      :get,
      "https://api.github.com/repos/#{full_repo_name}/pulls/#{pull_request_number}/files"
    ).with(
      headers: { 'Authorization' => "token #{auth_token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/pull_request_files.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_contents_request(token, options = {})
    fixture = options.fetch(:fixture, 'contents.json')
    file = options.fetch(:file, 'config/unicorn.rb')

    stub_request(
      :get,
      "https://api.github.com/repos/#{options[:repo_name]}/contents/#{file}?ref=#{options[:sha]}"
    ).with(
      headers: { 'Authorization' => "token #{token}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/#{fixture}"),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  private

  def stub_orgs_request(auth_token)
    stub_request(
      :get,
      'https://api.github.com/user/orgs'
    ).with(
      headers: { 'Authorization' => "token #{auth_token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/github_orgs_response.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_paginated_repo_requests(auth_token)
    stub_request(
      :get,
      'https://api.github.com/user/repos?page=1'
    ).with(
      headers: { 'Authorization' => "token #{auth_token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/github_repos_response_for_jimtom.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )

    stub_request(
      :get,
      'https://api.github.com/user/repos?page=2'
    ).with(
      headers: { 'Authorization' => "token #{auth_token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/github_repos_response_for_jimtom.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )

    stub_request(
      :get,
      'https://api.github.com/user/repos?page=3'
    ).with(
      headers: { 'Authorization' => "token #{auth_token}" }
    ).to_return(
      status: 200,
      body: '[]',
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_paginated_org_repo_requests(auth_token)
    stub_request(
      :get,
      'https://api.github.com/orgs/thoughtbot/repos?page=1'
    ).with(
      headers: { 'Authorization' => "token #{auth_token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/github_repos_response_for_jimtom.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )

    stub_request(
      :get,
      'https://api.github.com/orgs/thoughtbot/repos?page=2'
    ).with(
      headers: { 'Authorization' => "token #{auth_token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/github_repos_response_for_jimtom.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )

    stub_request(
      :get,
      'https://api.github.com/orgs/thoughtbot/repos?page=3'
    ).with(
      headers: { 'Authorization' => "token #{auth_token}" }
    ).to_return(
      status: 200,
      body: '[]',
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_comment_request(full_repo_name, pull_request_number, comment, commit_sha, file, line_number)
    stub_request(
      :post,
      "https://api.github.com/repos/#{full_repo_name}/pulls/#{pull_request_number}/comments"
    ).with(
      body: {
        body: comment,
        commit_id: commit_sha,
        path: file,
        position: line_number
      }.to_json
    ).to_return(status: 200)
  end

  def stub_pull_request_comments_request(full_repo_name, pull_request_number, token = auth_token)
    stub_request(
      :get,
      "https://api.github.com/repos/#{full_repo_name}/pulls/#{pull_request_number}/comments"
    ).with(
      headers: { 'Authorization' => "token #{token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/pull_request_comments.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stubbed_memberships_request(token)
    stub_request(
      :get,
      "https://api.github.com/user/memberships/orgs?state=pending"
    ).with(
      headers: { "Authorization" => "token #{token}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/github_org_memberships.json"),
      headers: { "Content-Type" => "application/json; charset=utf-8" }
    )
  end

  def stubbed_membership_update_request(token)
    stub_request(
      :patch,
      "https://api.github.com/user/memberships/orgs/invitocat"
    ).with(
      headers: { "Authorization" => "token #{token}" },
      body: { "state" => "active" }
    ).to_return(
      status: 200,
      body: File.read(
        "spec/support/fixtures/github_org_membership_update.json"
      ),
      headers: { "Content-Type" => "application/json; charset=utf-8" }
    )
  end

  private

  def auth_token
    AuthenticationHelper::GITHUB_TOKEN
  end
end
