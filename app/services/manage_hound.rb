require "app/models/github_team"

class ManageHound
  SERVICES_TEAM_NAME = "Services"

  pattr_initialize :repo_name, :github

  def self.run(repo_name, github)
    new(repo_name, github).run
  end

  def run
    raise NotImplementedError.new("must implement ##{__method__}")
  end

  private

  def repo
    @repo ||= github.repo(repo_name)
  end

  def github_username
    @github_username ||= ENV.fetch("HOUND_GITHUB_USERNAME")
  end

  def decorated_services_team
    if find_services_team
      GithubTeam.new(find_services_team)
    else
      nil
    end
  end

  def find_services_team
    @services_team ||= github.org_teams(org_name).detect do |team|
      team.name.downcase == SERVICES_TEAM_NAME.downcase
    end
  end

  def org_name
    repo.organization.login
  end
end
