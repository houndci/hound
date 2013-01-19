class GithubApi
  attr_reader :token

  def initialize(token)
    @token = token
  end

  def get_repos
    client = Octokit::Client.new(oauth_token: token)
    client.repos
  end
end
