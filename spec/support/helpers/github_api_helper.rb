module GithubApiHelper
  def stub_github_requests
    stub_request(:any, /.*api.github.com.*/)
  end

  def stub_repo_requests(auth_token)
    stub_paginated_repo_requests(auth_token)
    stub_orgs_request(auth_token)
    stub_paginated_org_repo_requests(auth_token)
  end

  def stub_hook_creation_request(auth_token, full_repo_name, callback_endpoint)
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

  def stub_hook_removal_request(full_repo_name, hook_id)
    stub_request(
      :delete,
      "https://api.github.com/repos/#{full_repo_name}/hooks/#{hook_id}"
    ).with(
      headers: { 'Authorization' => /^token \w+$/ }
    ).to_return(
      status: 204
    )
  end

  def stub_status_creation_request(full_repo_name, commit_sha, state, description)
    stub_request(
      :post,
      "https://api.github.com/repos/#{full_repo_name}/statuses/#{commit_sha}"
    ).with(
      body: %({"description":"#{description}","state":"#{state}"}),
      headers: { 'Authorization' => /^token \w+$/ }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/github_status_creation_response.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_error_status_creation_request(full_repo_name, commit_sha, state, description, target_url)
    stub_request(
      :post,
      "https://api.github.com/repos/#{full_repo_name}/statuses/#{commit_sha}"
    ).with(
      body: %({"description":"#{description}","target_url":"#{target_url}","state":"#{state}"}),
      headers: { 'Authorization' => /^token \w+$/ }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/github_status_creation_response.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_pull_request_files_request(full_repo_name, fixture = nil)
    fixture ||= 'pull_request_files.json'
    stub_request(
      :get,
      %r(https://api.github.com/repos/#{full_repo_name}/pulls/\d/files)
    ).with(
      headers: { 'Authorization' => /token \w+/ }
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
end
