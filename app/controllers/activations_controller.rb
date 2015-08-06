class ActivationsController < ApplicationController
  class FailedToActivate < StandardError; end
  class CannotActivatePaidRepo < StandardError; end

  before_action :check_repo_plan

  def create
    if activator.activate
      analytics.track_repo_activated(repo)
      render json: repo, status: :created
    else
      analytics.track_repo_activation_failed(repo)
      render json: { errors: activator.errors }, status: 502
    end
  end

  private

  def check_repo_plan
    if repo.plan_price > 0
      raise CannotActivatePaidRepo
    end
  end

  def activator
    @activator ||= RepoActivator.new(repo: repo, github_token: github_token)
  end

  def repo
    @repo ||= current_user.repos.find(params[:repo_id])
  end

  def github_token
    current_user.token
  end
end
