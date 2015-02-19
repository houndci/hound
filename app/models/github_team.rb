class GithubTeam
  pattr_initialize :team, :github

  def add_repo(repo_name)
    ensure_push_permission
    add_repo_to_team(repo_name)
  end

  def remove_repo(repo_name)
    github.remove_repo_from_team(team.id, repo_name)
  end

  def remove_user(github_username)
    remove_user_from_team(github_username)
  end

  def add_user(github_username)
    github.add_user_to_team(team.id, github_username)
  end

  private

  def has_pull_permission?
    team.permission == "pull"
  end

  def remove_user_from_team(github_username)
    team_repos = github.team_repos(team.id)

    if team_repos.empty?
      github.remove_user_from_team(team.id, github_username)
    else
      true
    end
  end

  def add_repo_to_team(repo_name)
    github.add_repo_to_team(team.id, repo_name)
  end

  def ensure_push_permission
    if has_pull_permission?
      github.update_team(team.id, permission: "push")
    end
  end
end
