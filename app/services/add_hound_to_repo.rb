# Adds @hounci user to the a private repository as collaborator,
# or to an organization team that has access to the repository
# This is necessary for making comments as the houndci user
class AddHoundToRepo < ManageHound
  def run
    if repo.organization
      add_user_to_org
    else
      add_collaborator_to_repo
    end
  end

  private

  def add_collaborator_to_repo
    github.add_collaborator(repo_name, github_username)
  end

  def add_user_to_org
    if team_with_admin_access
      github.add_user_to_team(team_with_admin_access.id, github_username)
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
    if team = decorated_services_team
      team.add_repo(repo_name)
    else
      team = GithubTeam.new(create_team, github)
    end

    team.add_user(github_username)
  end

  def create_team
    github.create_team(
      team_name: GITHUB_TEAM_NAME,
      org_name: org_name,
      repo_name: repo_name
    )
  end
end
