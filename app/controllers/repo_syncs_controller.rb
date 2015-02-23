class RepoSyncsController < ApplicationController
  def create
    JobQueue.push(
      RepoSynchronizationJob,
      current_user.id,
      session[:github_token]
    )
    head 201
  end
end
