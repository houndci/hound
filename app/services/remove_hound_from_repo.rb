require "app/services/manage_hound"

class RemoveHoundFromRepo < ManageHound
  def run
    if repo.organization
      remove_services_team_from_repo
    else
      remove_hound_from_repo
    end
  end

  private

  def remove_hound_from_repo
    github.remove_collaborator(repo_name, github_username)
  end

  def remove_services_team_from_repo
    team = find_services_team

    if team
      team_id = team.id
      remove_repo_from_team(team_id)
      remove_user_from_team(team_id)
    end
  end

  def remove_user_from_team(team_id)
    team_repos = github.team_repos(team_id)

    if team_repos.empty?
      github.remove_user_from_team(team_id, github_username)
    end
  end

  def remove_repo_from_team(team_id)
    github.remove_repo_from_team(team_id, repo_name)
  end
end
