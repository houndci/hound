class GithubTeam
  def initialize(team)
    @team = team
  end

  def has_pull_permission?
    team.permission == "pull"
  end

  def id
    team.id
  end

  def add_repo(github, repo_name)
    ensure_push_permission(github)
    add_repo_to_team(github, repo_name)
  end

  def remove_repo(github, repo_name)
    remove_repo_from_team(github, repo_name)
  end

  def remove_user(github, github_username)
    team_repos = github.team_repos(id)

    if team_repos.empty?
      github.remove_user_from_team(id, github_username)
    end
  end

  protected

  attr_reader :team

  private

  def remove_repo_from_team(github, repo_name)
    github.remove_repo_from_team(id, repo_name)
  end

  def add_repo_to_team(github, repo_name)
    github.add_repo_to_team(id, repo_name)
  end

  def ensure_push_permission(github)
    if has_pull_permission?
      github.update_team(id, permission: "push")
    end
  end
end
