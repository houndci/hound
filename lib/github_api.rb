class GithubApi
  attr_reader :username, :token

  def initialize(username, token)
    @username = username
    @token = token
  end

  def get_repos
    client = Octokit::Client.new(login: username, oauth_token: token)
    client.repos
  end
end
