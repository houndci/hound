class ActivationsController < ApplicationController
  respond_to :json

  def create
    repo = current_user.repos.find(params[:repo_id])

    if activator.activate(repo, current_user)
      render json: repo
    else
      head 404
    end
  end

  private

  def activator
    RepoActivator.new
  end
end
