class DeactivationsController < ApplicationController
  respond_to :json

  def create
    repo = current_user.repos.find(params[:repo_id])

    if  activator.deactivate(repo)
      render json: repo
    else
      head 502
    end
  end

  private

  def activator
    RepoActivator.new
  end
end
