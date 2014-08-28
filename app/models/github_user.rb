class GithubUser
  pattr_initialize :github_api

  def has_admin_access_through_team?(team_id)
    admin_teams.map(&:id).include?(team_id)
  end

  private

  def admin_teams
    teams = github_api.user_teams
    teams.select { |team| team.permission == 'admin' }
  end
end
