class ActivationsController < ApplicationController
  class FailedToActivate < StandardError; end
  class CannotActivatePaidRepo < StandardError; end

  respond_to :json

  before_action :check_repo_plan

  def create
    if activator.activate
      analytics.track_activated(repo)

      render json: repo, status: :created
    else
      head 502
    end
  end

  private

  def check_repo_plan
    if repo.plan_price > 0
      raise CannotActivatePaidRepo
    end
  end

  def activator
    RepoActivator.new(repo: repo, github_token: github_token)
  end

  def repo
    @repo ||= current_user.repos.find(params[:repo_id])
  end

  def github_token
    session.fetch(:github_token)
  end
end
