class ReposController < ApplicationController
  before_filter :load_repo, only: [:edit, :update]

  def index
    @repos = current_user.repos.order(:name)
  end

  def edit
  end

  def update
    if activate?
      activator.activate(
        @repo.github_id,
        @repo.full_github_name,
        current_user,
        github_api,
        "http://#{request.host_with_port}"
      )
    else
      @repo.deactivate
    end

    redirect_to repos_path, notice: 'Repo was updated'
  end

  def sync
    synchronization.start
    redirect_to repos_path
  end

  private

  def load_repo
    @repo ||= current_user.repos.find(params[:id])
  end

  def github_api
    GithubApi.new(current_user.github_token)
  end

  def activator
    RepoActivator.new
  end

  def synchronization
    RepoSynchronization.new(current_user)
  end

  def activate?
    params[:repo][:active] == '1'
  end
end
