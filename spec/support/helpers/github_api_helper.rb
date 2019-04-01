module GitHubApiHelper
  def stub_add_collaborator_request(username, repo_name, user_token)
    stub_request(
      :put,
      "https://api.github.com/repos/#{repo_name}/collaborators/#{username}"
    ).with(
      headers: { "Authorization" => "Bearer #{user_token}" },
    ).to_return(
      status: 204,
    )
  end

  def stub_remove_collaborator_request(username, repo_name, user_token)
    stub_request(
      :delete,
      "https://api.github.com/repos/#{repo_name}/collaborators/#{username}"
    ).with(
      headers: { "Authorization" => "Bearer #{user_token}" },
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
      headers: { "Authorization" => "Bearer #{token}" },
    ).to_return(
      status: 200,
      body: read_fixture("github_hook_creation_response.json"),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_failed_hook_creation_request(full_repo_name, callback_endpoint)
    stub_request(
      :post,
      "https://api.github.com/repos/#{full_repo_name}/hooks"
    ).with(
      body: %({"name":"web","config":{"url":"#{callback_endpoint}"},"events":["pull_request"],"active":true}),
      headers: { "Authorization" => "Bearer #{hound_token}" },
    ).to_return(
      status: 422,
      body: read_fixture("failed_hook.json"),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_hook_removal_request(full_repo_name, hook_id)
    url = "https://api.github.com/repos/#{full_repo_name}/hooks/#{hook_id}"
    stub_request(:delete, url).
      with(headers: { "Authorization" => /^Bearer \w+$/ }).
      to_return(status: 204)
  end

  def stub_pull_request_files_request(full_repo_name, pull_request_number)
    stub_request(
      :get,
      "https://api.github.com/repos/#{full_repo_name}/pulls/#{pull_request_number}/files?per_page=100"
    ).with(
      headers: { "Authorization" => "Bearer #{hound_token}" },
    ).to_return(
      status: 200,
      body: read_fixture("pull_request_files.json"),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_repos_requests(token)
    repos_url = "https://api.github.com/user/repos"
    headers = { "Content-Type" => "application/json; charset=utf-8" }

    stub_request(:get, "#{repos_url}?per_page=100").
      with(headers: { "Authorization" => "Bearer #{token}" }).
      to_return(
        status: 200,
        body: read_fixture("github_repos_response_for_jimtom.json"),
        headers: headers.merge(
          "Link" => %(<#{repos_url}?page=2&per_page=100>; rel="next"),
        ),
      )

    stub_request(:get, "#{repos_url}?page=2&per_page=100").
      with(headers: { "Authorization" => "Bearer #{token}" }).
      to_return(
        status: 200,
        body: read_fixture("github_repos_response_for_jimtom_page2.json"),
        headers: headers.merge(
          "Link" => %(<#{repos_url}?page=3&per_page=100>; rel="next"),
        ),
      )

    stub_request(:get, "#{repos_url}?page=3&per_page=100").
      with(headers: { "Authorization" => "Bearer #{token}" }).
      to_return(status: 200, body: "[]", headers: headers)
  end

  def stub_review_request(repo_name, pr_number, comments, body)
    url = "https://api.github.com/repos/#{repo_name}/pulls/#{pr_number}/reviews"

    stub_request(:post, url).
      with(body: { event: "COMMENT", body: body, comments: comments }.to_json).
      to_return(status: 200)
  end

  def stub_pull_request_comments_request(
    full_repo_name,
    pull_request_number,
    username
  )
    comments_body = read_fixture("pull_request_comments.json").
      gsub("the_hound_user", username)
    url = "https://api.github.com/repos/#{full_repo_name}/pulls/" +
      "#{pull_request_number}/comments"
    headers = { "Content-Type" => "application/json; charset=utf-8" }

    stub_request(:get, "#{url}?per_page=100").
      with(headers: { "Authorization" => "Bearer #{hound_token}" }).
      to_return(status: 200, body: comments_body, headers: headers.merge(
        "Link" => %(<#{url}?page=2&per_page=100>; rel="next"),
      ))
    stub_request(:get, "#{url}?page=2&per_page=100").
      to_return(status: 200, body: "[]", headers: headers)
  end

  def stub_status_request(repo_name, sha, state, description, target_url = nil)
    stub_request(
      :post,
      "https://api.github.com/repos/#{repo_name}/statuses/#{sha}",
    ).with(
      headers: { "Authorization" => "Bearer #{hound_token}" },
      body: status_request_body(description, state, target_url),
    ).to_return(status_request_return_value)
  end

  def stub_repository_invitations(repo_name)
    url = "https://api.github.com/user/repository_invitations?per_page=100"
    stub_request(:get, url).
      to_return(
        headers: { "Content-Type" => "application/json; charset=utf-8" },
        body: [{ id: 1234, repository: { full_name: repo_name } }].to_json,
      )
  end

  private

  def status_request_return_value
    {
      status: 201,
      body: read_fixture("github_status_response.json"),
      headers: { "Content-Type" => "application/json; charset=utf-8" },
    }
  end

  def status_request_body(description, state, target_url)
    {
      context: "Hound",
      description: description,
      state: state,
      target_url: target_url,
    }
  end

  def read_fixture(filename)
    File.read(File.join("spec", "support", "fixtures", filename))
  end

  def hound_token
    Hound::GITHUB_TOKEN
  end
end
