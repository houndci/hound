class RepoSyncsController < ApplicationController
  def create
    unless current_user.refreshing_repos?
      RepoSynchronizationJob.perform_later(
        current_user.id,
        session[:github_token]
      )
    end

    head 201
  end
end
