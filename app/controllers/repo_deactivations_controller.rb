class RepoDeactivationsController < ApplicationController
  def create
    repo = Repo.find_by_github_id_and_user(params[:github_id], current_user)
    repo.deactivate

    render nothing: true
  end
end
