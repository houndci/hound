class ReposController < ApplicationController
  def index
    @github_repos = github_repos
    @active_repo_ids = Repo.active_repo_ids_in(@github_repos.map(&:id))
  end

  private

  def github_repos
    api = GithubApi.new(current_user.github_token)
    api.get_repos
  end
end
