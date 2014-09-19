class ActivationsController < ApplicationController
  class FailedToActivate < StandardError; end
  class CannotActivatePrivateRepo < StandardError; end

  respond_to :json

  # before_action :check_privacy

  def create
    if activator.activate(repo, session[:github_token])
      analytics.track_activated(repo)
      render json: repo, status: :created
    else
      report_exception(
        FailedToActivate.new('Failed to activate repo'),
        user_id: current_user.id,
        repo_id: params[:repo_id]
      )
      head 502
    end
  end

  private

  def repo
    @repo ||= current_user.repos.find(params[:repo_id])
  end

  def activator
    RepoActivator.new
  end

  def check_privacy
    raise CannotActivatePrivateRepo if repo.private?
  end
end
