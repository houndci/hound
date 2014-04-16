class ActivationsController < ApplicationController
  class FailedToActivate < StandardError; end

  respond_to :json

  def create
    repo = current_user.repos.find(params[:repo_id])

    if activator.activate(repo, session[:github_token])
      render json: repo, status: :created
    else
      report_exception(
        FailedToActivate.new('Failed to activate repo'),
        repo_id: params[:repo_id]
      )
      head 502
    end
  end

  private

  def activator
    RepoActivator.new
  end
end
