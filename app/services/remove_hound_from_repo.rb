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
    if decorated_services_team
      decorated_services_team.remove_repo(github, repo_name)
      decorated_services_team.remove_user(github, github_username)
    end
  end
end
