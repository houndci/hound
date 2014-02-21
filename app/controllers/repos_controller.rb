class ReposController < ApplicationController
  respond_to :json

  def index
    respond_with current_user.repos.order(:full_github_name)
  end

  def update
    repo = current_user.repos.find(params[:id])

    if params[:active]
      activator.activate(repo, current_user)
    else
      activator.deactivate(repo)
    end

    respond_with repo
  end

  private

  def activator
    RepoActivator.new
  end
end
