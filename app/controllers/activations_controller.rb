class ActivationsController < ApplicationController
  respond_to :json

  def create
    repo = current_user.repos.find(params[:repo_id])

    if activator.activate(repo, session[:github_token])
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
