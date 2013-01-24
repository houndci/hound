class RepoActivationsController < ApplicationController
  def create
    find_repo(params[:github_id]).activate

    render nothing: true
  end

  def destroy
    find_repo(params[:id]).deactivate

    render nothing: true
  end

  private

  def find_repo(github_id)
    Repo.find_by_github_id_and_user(github_id, current_user)
  end
end
