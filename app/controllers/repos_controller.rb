class ReposController < ApplicationController
  def index
    api = GithubApi.new(current_user.github_token)
    @repos = api.get_repos
  end

  def show
    repo = current_user.github_repo(params[:id])

    if repo
      render json: { active: repo.active }
    else
      render json: { active: false }
    end
  end
end
