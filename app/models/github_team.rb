class GithubTeam
  def initialize(team, github)
    @team = team
    @github = github
  end

  def has_pull_permission?
    team.permission == "pull"
  end

  def id
    team.id
  end

  def add_repo(repo_name)
    ensure_push_permission
    add_repo_to_team(repo_name)
  end

  def remove_repo(repo_name)
    remove_repo_from_team(repo_name)
  end

  def remove_user(github_username)
    remove_user_from_team(github_username)
  end

  protected

  attr_reader :team, :github

  private

  def remove_user_from_team(github_username)
    team_repos = github.team_repos(id)

    if team_repos.empty?
      github.remove_user_from_team(id, github_username)
    end
  end

  def remove_repo_from_team(repo_name)
    github.remove_repo_from_team(id, repo_name)
  end

  def add_repo_to_team(repo_name)
    github.add_repo_to_team(id, repo_name)
  end

  def ensure_push_permission
    if has_pull_permission?
      github.update_team(id, permission: "push")
    end
  end
end
