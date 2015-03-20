class ManageHound
  GITHUB_TEAM_NAME = "Services"

  static_facade :run, :repo_name, :github

  attr_implement :run

  private

  def repo
    @repo ||= github.repo(repo_name)
  end

  def github_username
    ENV.fetch("HOUND_GITHUB_USERNAME")
  end

  def decorated_services_team
    if find_services_team
      GithubTeam.new(find_services_team, github)
    end
  end

  def find_services_team
    @services_team ||= github.org_teams(org_name).detect do |team|
      team.name.downcase == GITHUB_TEAM_NAME.downcase
    end
  end

  def org_name
    repo.organization.login
  end
end
