class DeactivationsController < ApplicationController
  class FailedToActivate < StandardError; end
  class CannotDeactivateRepoWithSubscription < StandardError; end

  respond_to :json

  before_action :check_for_subscription

  def create
    if activator.deactivate(repo, session[:github_token])
      analytics.track_deactivated(repo)
      render json: repo, status: :created
    else
      report_exception(
        FailedToActivate.new('Failed to deactivate repo'),
        user_id: current_user.id, repo_id: params[:repo_id]
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

  def check_for_subscription
    if repo.subscription
      raise CannotDeactivateRepoWithSubscription
    end
  end
end
