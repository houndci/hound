class GithubUser
  def initialize(github_api)
    @github_api = github_api
  end

  def has_admin_access_through_team?(team_id)
    admin_teams.map(&:id).include?(team_id)
  end

  private

  def admin_teams
    teams = @github_api.user_teams
    teams.select { |team| team.permission == 'admin' }
  end
end
