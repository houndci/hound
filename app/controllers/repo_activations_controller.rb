class RepoActivationsController < ApplicationController
  def create
    repo = Repo.find_by_github_id_and_user(params[:github_id], current_user)
    repo.activate

    render nothing: true
  end
end
