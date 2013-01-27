class ReposController < ApplicationController
  def index
    api = GithubApi.new(current_user.github_token)
    @repos = api.get_repos
  end

  def show
    repo = current_user.repos.where(github_id: params[:id]).first

    if repo
      render json: { active: repo.active }
    else
      render json: { active: false }
    end
  end
end
