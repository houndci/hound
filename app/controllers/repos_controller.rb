class ReposController < ApplicationController
  respond_to :json

  def index
    respond_with current_user.repos.order(:name)
  end

  def update
    repo = current_user.repos.find(params[:id])

    if params[:active]
      activator.activate(repo, github_api)
    else
      repo.deactivate
    end

    respond_with repo
  end

  def sync
    synchronization.start
    redirect_to root_path
  end

  private

  def github_api
    GithubApi.new(current_user.github_token)
  end

  def activator
    RepoActivator.new
  end

  def synchronization
    RepoSynchronization.new(current_user)
  end
end
