class DeactivationsController < ApplicationController
  respond_to :json

  def create
    repo = current_user.repos.find(params[:repo_id])

    unless activator.deactivate(repo)
      render status: 404
    end

    render json: repo
  end

  private

  def activator
    RepoActivator.new
  end
end
