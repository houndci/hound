class RemoveHoundFromRepo < ManageHound
  def run
    if repo.organization
      remove_repo_from_services_team
    else
      remove_hound_from_repo
    end
  end

  private

  def remove_hound_from_repo
    github.remove_collaborator(repo_name, github_username)
  end

  def remove_repo_from_services_team
    if team = decorated_services_team
      team.remove_repo(repo_name)
      team.remove_user(github_username)
    end
  end
end
