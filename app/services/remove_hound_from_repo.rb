class RemoveHoundFromRepo < ManageHound
  def run
    if repo.organization
      remove_hound_from_organization
    else
      remove_hound_from_repo
    end
  end

  private

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
end
