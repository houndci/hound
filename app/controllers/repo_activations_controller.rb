class RepoActivationsController < ApplicationController
  def create
    repo = current_user.repos.where(github_id: params[:github_id]).first

    if repo
      repo.activate
    else
      current_user.repos.create(github_id: params[:github_id], active: true)
    end

    render nothing: true
  end

  def destroy
    repo = current_user.repos.where(github_id: params[:id]).first
    repo.deactivate

    render nothing: true
  end
end
