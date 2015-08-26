module GithubApiHelper
  def stub_add_collaborator_request(username, repo_name, user_token)
    stub_request(
      :put,
      "https://api.github.com/repos/#{repo_name}/collaborators/#{username}"
    ).with(
      headers: { "Authorization" => "token #{user_token}" }
    ).to_return(
      status: 204,
    )
  end

  def stub_remove_collaborator_request(username, repo_name, user_token)
    stub_request(
      :delete,
      "https://api.github.com/repos/#{repo_name}/collaborators/#{username}"
    ).with(
      headers: { "Authorization" => "token #{user_token}" }
    ).to_return(
      status: 204,
    )
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

  def stub_create_team_request(org, team_name, repo_name, user_token)
    stub_request(
      :post,
      "https://api.github.com/orgs/#{org}/teams"
    ).with(
      body: {
        name: team_name,
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

  def stub_update_team_permission_request(team_id)
    json_response = File.read("spec/support/fixtures/team_update.json")
    stub_request(
      :patch,
      "https://api.github.com/teams/#{team_id}"
    ).with(
      headers: { "Authorization" => /^token \w+$/ }
    ).to_return(
      status: 200,
      body: json_response,
      headers: { "Content-Type" => "application/json; charset=utf-8" }
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

  def stub_team_repos_request(team_id, user_github_token)
    stub_request(
      :get,
      "https://api.github.com/teams/#{team_id}/repos?per_page=100"
    ).with(
      headers: { "Authorization" => "token #{user_github_token}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/team_repos.json"),
      headers: { "Content-Type" => "application/json; charset=utf-8" }
    )
  end

  def stub_remove_repo_from_team_request(team_id, repo_name, user_github_token)
    stub_request(
      :delete,
      "https://api.github.com/teams/#{team_id}/repos/#{repo_name}"
    ).with(
      headers: { "Authorization" => "token #{user_github_token}" }
    ).to_return(
      status: 200
    )
  end

  def stub_remove_user_from_team_request(team_id, username, user_github_token)
    stub_request(
      :delete,
      "https://api.github.com/teams/#{team_id}/memberships/#{username}"
    ).with(
      headers: { "Authorization" => "token #{user_github_token}" }
    ).to_return(
      status: 200
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

  def stub_add_user_to_team_request(team_id, username, user_token)
    url = "https://api.github.com/teams/#{team_id}/memberships/#{username}"
    stub_request(:put, url).
      with(headers: { "Authorization" => "token #{user_token}" }).
      to_return(status: 200)
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
      body: {
        context: "hound",
        description: description,
        state: state,
        target_url: nil
      }
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

  def stub_scopes_request(token: "token", scopes: "public_repo,user:email")
    stub_request(:get, "https://api.github.com/user").
      with(
        headers: {
          "Accept" => "application/vnd.github.v3+json",
          "Authorization" => "token #{token}",
          "Content-Type" => "application/json",
          "User-Agent" => "Octokit Ruby Gem 4.0.0",
        }
      ).
      to_return(
        status: 200, body: "", headers: { "X-OAuth-Scopes" => scopes }
      )
  end

  private

  def stub_repos_requests(token)
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
      body: File.read("spec/support/fixtures/github_repos_response_for_jimtom_page2.json"),
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
      "Hound is busy reviewing changes..."
    )
    stub_status_request(
      repo_name,
      sha,
      "success",
      anything
    )
  end

  def stub_status_request(repo_name, sha, state, description, target_url = nil)
    stub_request(
      :post,
      "https://api.github.com/repos/#{repo_name}/statuses/#{sha}",
    ).with(
      headers: { "Authorization" => "token #{hound_token}" },
      body: status_request_body(description, state, target_url),
    ).to_return(status_request_return_value)
  end

  def status_request_return_value
    {
      status: 201,
      body: File.read("spec/support/fixtures/github_status_response.json"),
      headers: { "Content-Type" => "application/json; charset=utf-8" },
    }
  end

  def status_request_body(description, state, target_url)
    {
      context: "hound",
      description: description,
      state: state,
      target_url: target_url,
    }
  end

  def hound_token
    Hound::GITHUB_TOKEN
  end
end
