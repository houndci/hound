class GithubUser
  def initialize(client)
    @client = client
  end

  def admin_access_teams
    teams = @client.user_teams
    teams.keep_if { |team| team.permission == 'admin' }
  end
end
