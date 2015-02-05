class RemoveHoundFromRepo
  SERVICES_TEAM_NAME = "Services"

  pattr_initialize :repo_name, :github

  def self.run(repo_name, github)
    new(repo_name, github).run
  end

  def run
    if repo.organization
      remove_hound_from_organization
    else
      remove_hound_from_repo
    end
  end

  private

  def repo
    @repo ||= github.repo(repo_name)
  end

  def remove_hound_from_repo
    github.remove_collaborator(repo_name, github_username)
  end

  def remove_hound_from_organization
    team = find_services_team

    if team
      team_id = team.id
      remove_repo_from_team(team_id)
      delete_team(team_id)
    end
  end

  def delete_team(team_id)
    team_repos = github.team_repos(team_id)

    if team_repos.count == 0
      github.delete_team(team_id)
    end
  end

  def remove_repo_from_team(team_id)
    github.remove_repo_from_team(team_id, repo_name)
  end

  def github_username
    @github_username ||= ENV.fetch("HOUND_GITHUB_USERNAME")
  end

  def find_services_team
    github.org_teams(org_name).detect do |team|
      team.name.downcase == SERVICES_TEAM_NAME.downcase
    end
  end

  def org_name
    repo.organization.login
  end
end
