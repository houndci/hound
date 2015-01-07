module GithubApiHelper
  def stub_add_collaborator_request(full_repo_name, token)
    url = "https://api.github.com/repos/#{full_repo_name}/collaborators/houndci"
    stub_request(:put, url).
      with(headers: { "Authorization" => "token #{token}" }).
      to_return(status: 204)
  end

  def stub_repo_requests(user_token)
    stub_paginated_repo_requests(user_token)
    stub_orgs_request(user_token)
    stub_paginated_org_repo_requests(user_token)
  end

  def stub_repo_request(repo_name, token)
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

  def stub_repo_with_org_request(repo_name, token = hound_token)
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

  def stub_team_creation_request(org, repo_name, user_token)
    stub_request(
      :post,
      "https://api.github.com/orgs/#{org}/teams"
    ).with(
      body: {
        name: 'Services',
        repo_names: [repo_name],
        permission: "push"
      }.to_json,
      headers: { "Authorization" => "token #{user_token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/team_creation.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_failed_team_creation_request(org, repo_name, user_token)
    stub_request(
      :post,
      "https://api.github.com/orgs/#{org}/teams"
    ).with(
      body: {
        name: 'Services',
        repo_names: [repo_name],
        permission: "push"
      }.to_json,
      headers: { "Authorization" => "token #{user_token}" }
    ).to_return(
      status: 422,
      body: File.read('spec/support/fixtures/failed_team_creation.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_repo_teams_request(repo_name, user_github_token)
    stub_request(
      :get,
      "https://api.github.com/repos/#{repo_name}/teams?per_page=100"
    ).with(
      headers: { "Authorization" => "token #{user_github_token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/repo_teams.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_user_teams_request(user_token)
    stub_request(
      :get,
      "https://api.github.com/user/teams?per_page=100"
    ).with(
      headers: { "Authorization" => "token #{user_token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/user_teams.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_empty_repo_teams_request(repo_name, user_token)
    stub_request(
      :get,
      "https://api.github.com/repos/#{repo_name}/teams?per_page=100"
    ).with(
      headers: { "Authorization" => "token #{user_token}" }
    ).to_return(
      status: 200,
      body: '[]',
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_org_teams_request(org_name, user_token)
    stub_request(
      :get,
      "https://api.github.com/orgs/#{org_name}/teams?per_page=100"
    ).with(
      headers: { "Authorization" => "token #{user_token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/repo_teams.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_paginated_org_teams_request(org_name, user_token)
    json_response =
      File.read("spec/support/fixtures/org_teams_with_services_team.json")

    stub_request(
      :get,
      "https://api.github.com/orgs/#{org_name}/teams?per_page=100"
    ).with(
      headers: { "Authorization" => "token #{user_token}" }
    ).to_return(
      status: 200,
      body: "[]",
      headers: {
        "Link" => %(<https://api.github.com/orgs/#{org_name}/teams?page=2&per_page=100>; rel="next"),
        "Content-Type" => "application/json; charset=utf-8"
      }
    )

    stub_request(
      :get,
      "https://api.github.com/orgs/#{org_name}/teams?page=2&per_page=100"
    ).with(
      headers: { "Authorization" => "token #{user_token}" }
    ).to_return(
      status: 200,
      body: json_response,
      headers: { "Content-Type" => "application/json; charset=utf-8" }
    )
  end

  def stub_add_repo_to_team_request(repo_name, team_id, user_token)
    stub_request(
      :put,
      "https://api.github.com/teams/#{team_id}/repos/#{repo_name}"
    ).with(
      headers: { "Authorization" => "token #{user_token}" }
    ).to_return(
      status: 204
    )
  end

  def stub_org_teams_with_services_request(org_name, user_token)
    json_response = File.read(
      "spec/support/fixtures/org_teams_with_services_team.json"
    )
    stub_request(
      :get,
      "https://api.github.com/orgs/#{org_name}/teams?per_page=100"
    ).with(
      headers: { "Authorization" => "token #{user_token}" }
    ).to_return(
      status: 200,
      body: json_response,
      headers: { "Content-Type" => "application/json; charset=utf-8" }
    )
  end

  def stub_org_teams_with_lowercase_services_request(org_name, token)
    json_response = File.read(
      "spec/support/fixtures/org_teams_with_lowercase_services_team.json"
    )
    stub_request(
      :get,
      "https://api.github.com/orgs/#{org_name}/teams?per_page=100"
    ).with(
      headers: { "Authorization" => "token #{token}" }
    ).to_return(
      status: 200,
      body: json_response,
      headers: { "Content-Type" => "application/json; charset=utf-8" }
    )
  end

  def stub_chained_org_teams_request(org_name, user_token)
    no_services_team_json_response =
      File.read("spec/support/fixtures/repo_teams.json")
    services_team_json_response =
      File.read("spec/support/fixtures/org_teams_with_services_team.json")
    stub_request(
      :get,
      "https://api.github.com/orgs/#{org_name}/teams?per_page=100"
    ).with(
      headers: { "Authorization" => "token #{user_token}" }
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

  def stub_add_user_to_team_request(username, team_id, user_token)
    stub_request(
      :put,
      "https://api.github.com/teams/#{team_id}/memberships/#{username}"
    ).with(
      headers: {
        "Authorization" => "token #{user_token}",
        "Accept" => "application/vnd.github.the-wasp-preview+json"
      }
    ).to_return(
      status: 200
    )
  end

  def stub_failed_add_user_to_team_request(username, team_id, user_github_token)
    stub_request(
      :put,
      "https://api.github.com/teams/#{team_id}/memberships/#{username}"
    ).with(
      headers: {
        "Authorization" => "token #{user_github_token}",
        "Accept" => "application/vnd.github.the-wasp-preview+json"
      }
    ).to_return(
      status: 404
    )
  end

  def stub_add_user_to_repo_request(username, repo_name, user_token)
    stub_request(
      :put,
      "https://api.github.com/repos/#{repo_name}/collaborators/#{username}"
    ).with(
      body: '{}',
      headers: { "Authorization" => "token #{user_token}" }
    ).to_return(
      status: 204,
    )
  end

  def stub_hook_creation_request(full_repo_name, callback_endpoint, token)
    stub_request(
      :post,
      "https://api.github.com/repos/#{full_repo_name}/hooks"
    ).with(
      body: %({"name":"web","config":{"url":"#{callback_endpoint}"},"events":["pull_request"],"active":true}),
      headers: { "Authorization" => "token #{token}" }
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
      headers: { "Authorization" => "token #{hound_token}" }
    ).to_return(
      status: 422,
      body: File.read('spec/support/fixtures/failed_hook.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_failed_status_creation_request(repo_name, sha, state, description)
    stub_request(
      :post,
      "https://api.github.com/repos/#{repo_name}/statuses/#{sha}"
    ).with(
      headers: { "Authorization" => "token #{hound_token}" },
      body: { context: "hound", description: description, state: state }
    ).to_return(
      status: 404,
      headers: { "Content-Type" => "application/json; charset=utf-8" }
    )
  end

  def stub_hook_removal_request(full_repo_name, hook_id)
    url = "https://api.github.com/repos/#{full_repo_name}/hooks/#{hook_id}"
    stub_request(:delete, url).
      with(headers: { 'Authorization' => /^token \w+$/ }).
      to_return(status: 204)
  end

  def stub_commit_request(full_repo_name, commit_sha)
    stub_request(
      :get,
      "https://api.github.com/repos/#{full_repo_name}/commits/#{commit_sha}"
    ).with(
      headers: { "Authorization" => "token #{hound_token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/commit.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_pull_request_files_request(full_repo_name, pull_request_number)
    stub_request(
      :get,
      "https://api.github.com/repos/#{full_repo_name}/pulls/#{pull_request_number}/files?per_page=100"
    ).with(
      headers: { "Authorization" => "token #{hound_token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/pull_request_files.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_contents_request(options = {})
    fixture = options.fetch(:fixture, 'contents.json')
    file = options.fetch(:file, 'config/unicorn.rb')

    stub_request(
      :get,
      "https://api.github.com/repos/#{options[:repo_name]}/contents/#{file}?ref=#{options[:sha]}"
    ).with(
      headers: { "Authorization" => "token #{hound_token}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/#{fixture}"),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  private

  def stub_orgs_request(token)
    stub_request(
      :get,
      'https://api.github.com/user/orgs'
    ).with(
      headers: { "Authorization" => "token #{token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/github_orgs_response.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_paginated_repo_requests(token)
    repos_url = "https://api.github.com/user/repos"

    stub_request(
      :get,
      "#{repos_url}?per_page=100"
    ).with(
      headers: { "Authorization" => "token #{token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/github_repos_response_for_jimtom.json'),
      headers: {
        "Link" => %(<#{repos_url}?page=2&per_page=100>; rel="next"),
        "Content-Type" => "application/json; charset=utf-8",
      }
    )

    stub_request(
      :get,
      "#{repos_url}?page=2&per_page=100"
    ).with(
      headers: { "Authorization" => "token #{token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/github_repos_response_for_jimtom.json'),
      headers: {
        "Link" => %(<#{repos_url}?page=3&per_page=100>; rel="next"),
        "Content-Type" => "application/json; charset=utf-8",
      }
    )

    stub_request(
      :get,
      "#{repos_url}?page=3&per_page=100"
    ).with(
      headers: { "Authorization" => "token #{token}" }
    ).to_return(
      status: 200,
      body: '[]',
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_paginated_org_repo_requests(token)
    org_repos_url = "https://api.github.com/orgs/thoughtbot/repos"

    stub_request(
      :get,
      "#{org_repos_url}?per_page=100"
    ).with(
      headers: { "Authorization" => "token #{token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/github_repos_response_for_jimtom.json'),
      headers: {
        "Link" => %(<#{org_repos_url}?page=2&per_page=100>; rel="next"),
        "Content-Type" => "application/json; charset=utf-8",
      }
    )

    stub_request(
      :get,
      "#{org_repos_url}?page=2&per_page=100"
    ).with(
      headers: { "Authorization" => "token #{token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/github_repos_response_for_jimtom.json'),
      headers: {
        "Link" => %(<#{org_repos_url}?page=3&per_page=100>; rel="next"),
        "Content-Type" => "application/json; charset=utf-8",
      }
    )

    stub_request(
      :get,
      "#{org_repos_url}?page=3&per_page=100"
    ).with(
      headers: { "Authorization" => "token #{token}" }
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

  def stub_pull_request_comments_request(full_repo_name, pull_request_number)
    comments_body =
      File.read("spec/support/fixtures/pull_request_comments.json")
    url = "https://api.github.com/repos/#{full_repo_name}/pulls/" +
      "#{pull_request_number}/comments"
    headers = { "Content-Type" => "application/json; charset=utf-8" }

    stub_request(:get, "#{url}?per_page=100").
      with(headers: { "Authorization" => "token #{hound_token}" }).
      to_return(status: 200, body: comments_body, headers: headers.merge(
        "Link" => %(<#{url}?page=2&per_page=100>; rel="next"),
      ))
    stub_request(:get, "#{url}?page=2&per_page=100").
      to_return(status: 200, body: "[]", headers: headers)
  end

  def stub_memberships_request
    stub_request(
      :get,
      "https://api.github.com/user/memberships/orgs?per_page=100&state=pending"
    ).with(
      headers: { "Authorization" => "token #{hound_token}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/github_org_memberships.json"),
      headers: { "Content-Type" => "application/json; charset=utf-8" }
    )
  end

  def stub_membership_update_request
    stub_request(
      :patch,
      "https://api.github.com/user/memberships/orgs/invitocat"
    ).with(
      headers: { "Authorization" => "token #{hound_token}" },
      body: { "state" => "active" }
    ).to_return(
      status: 200,
      body: File.read(
        "spec/support/fixtures/github_org_membership_update.json"
      ),
      headers: { "Content-Type" => "application/json; charset=utf-8" }
    )
  end

  def stub_status_requests(repo_name, sha)
    stub_status_request(
      repo_name,
      sha,
      "pending",
      "Hound is reviewing changes."
    )
    stub_status_request(
      repo_name,
      sha,
      "success",
      "Hound has reviewed the changes."
    )
  end

  def stub_status_request(full_repo_name, sha, state, description)
    stub_request(
      :post,
      "https://api.github.com/repos/#{full_repo_name}/statuses/#{sha}"
    ).with(
      headers: { "Authorization" => "token #{hound_token}" },
      body: { context: "hound", description: description, state: state }
    ).to_return(
      status: 201,
      body: File.read("spec/support/fixtures/github_status_response.json"),
      headers: { "Content-Type" => "application/json; charset=utf-8" }
    )
  end

  private

  def hound_token
    ENV["HOUND_GITHUB_TOKEN"]
  end
end
