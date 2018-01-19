class ActivationsController < ApplicationController
  class FailedToActivate < StandardError; end
  class CannotActivatePaidRepo < StandardError; end

  before_action :ensure_repo_allowed

  def create
    if activator.activate
      render json: repo, status: :created
    else
      analytics.track_repo_activation_failed(repo)
      render json: { errors: activator.errors }, status: 502
    end
  end

  private

  def ensure_repo_allowed
    if repo.private? && !repo.owner.whitelisted?
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
