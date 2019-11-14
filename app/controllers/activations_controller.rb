class ActivationsController < ApplicationController
  class CannotActivatePaidRepo < StandardError; end

  before_action :ensure_repo_allowed

  def create
    repo.activate

    render json: repo, status: :created
  end

  private

  def ensure_repo_allowed
    if repo.private? && !repo.owner.whitelisted?
      raise CannotActivatePaidRepo
    end
  end

  def repo
    @repo ||= current_user.repos.find(params[:repo_id])
  end
end
