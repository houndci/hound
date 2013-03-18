module GithubApiHelper
  def stub_repos_request(auth_token = 'authtoken')
    stub_request(
      :get,
      'https://api.github.com/user/repos'
    ).with(
      headers: { 'Authorization' => "token #{auth_token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/github_repos_response_for_jimtom.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
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

  def stub_hook_removal_request(auth_token, full_repo_name, hook_id)
    stub_request(
      :delete,
      "https://api.github.com/repos/#{full_repo_name}/hooks/#{hook_id}"
    ).with(
      headers: { 'Authorization' => "token #{auth_token}" }
    ).to_return(
      status: 204
    )
  end

  def stub_status_creation_request(auth_token, full_repo_name, commit_hash, state, description)
    stub_request(
      :post,
      "https://api.github.com/repos/#{full_repo_name}/statuses/#{commit_hash}"
    ).with(
      body: %({"description":"#{description}","state":"#{state}"}),
      headers: { 'Authorization'=>'token authtoken' }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/github_status_creation_response.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end
end
