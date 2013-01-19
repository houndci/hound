module GithubApiHelper
  def stub_repos_request
    stub_request(
      :get,
      'https://api.github.com/user/repos'
    ).with(
      :headers => { 'Authorization' => 'token authtoken' }
    ).to_return(
      :status => 200,
      :body => File.read('spec/support/fixtures/github_repos_response_for_jimtom.json'),
      :headers => { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end
end
