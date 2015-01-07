class RepoSyncsController < ApplicationController
  respond_to :json

  def create
    RepoSynchronizationJob.perform_later(
      current_user.id,
      session[:github_token]
    )
    head 201
  end
end
