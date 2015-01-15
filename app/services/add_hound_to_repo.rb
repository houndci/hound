# Adds @hounci user to the a private repository as collaborator,
# or to an organization team that has access to the repository
# This is necessary for making comments as the houndci user
class AddHoundToRepo
  SERVICES_TEAM_NAME = "Services"

  pattr_initialize :repo_name, :github

  def self.run(repo_name, github)
    new(repo_name, github).run
  end

  def run
    if repo.organization
      add_user_to_org
    else
      add_collaborator_to_repo
    end
  end

  private

  def repo
    @repo ||= github.repo(repo_name)
  end

  def add_collaborator_to_repo
    github.add_collaborator(repo_name, github_username)
  end

  def add_user_to_org
    if team_with_admin_access
      github.add_user_to_team(github_username, team_with_admin_access.id)
    else
      add_user_and_repo_to_services_team
    end
  end

  def team_with_admin_access
    @team_with_admin_access ||= begin
      repo_teams = github.repo_teams(repo_name)
      token_bearer = GithubUser.new(github)

      repo_teams.detect do |repo_team|
        token_bearer.has_admin_access_through_team?(repo_team.id)
      end
    end
  end

  def add_user_and_repo_to_services_team
    team = find_services_team

    if team
      ensure_push_permission(team)
      github.add_repo_to_team(team.id, repo_name)
    else
      team = github.create_team(
        team_name: SERVICES_TEAM_NAME,
        org_name: org_name,
        repo_name: repo_name
      )
    end

    github.add_user_to_team(github_username, team.id)
  end

  def find_services_team
    github.org_teams(org_name).detect do |team|
      team.name.downcase == SERVICES_TEAM_NAME.downcase
    end
  end

  def ensure_push_permission(team)
    if team.permission == "pull"
      github.update_team(team.id, permission: "push")
    end
  end

  def org_name
    repo.organization.login
  end

  def github_username
    @github_username ||= ENV.fetch("HOUND_GITHUB_USERNAME")
  end
end
