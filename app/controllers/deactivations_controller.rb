class DeactivationsController < ApplicationController
  class FailedToActivate < StandardError; end
  class CannotDeactivateRepoWithSubscription < StandardError; end

  before_action :check_for_subscription

  def create
    if activator.deactivate
      analytics.track_repo_deactivated(repo)
      render json: repo, status: :created
    else
      head 502
    end
  end

  private

  def activator
    RepoActivator.new(repo: repo, github_token: github_token)
  end

  def repo
    @repo ||= current_user.repos.find(params[:repo_id])
  end

  def github_token
    current_user.token
  end

  def check_for_subscription
    if repo.subscription
      raise CannotDeactivateRepoWithSubscription
    end
  end
end
