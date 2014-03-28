class HomeController < ApplicationController
  def index
    if current_user.repos.empty?
      enqueue_repo_sync_job
    end
  end

  private

  def enqueue_repo_sync_job
    sync_job = RepoSynchronizationJob.new(current_user.id)
    Delayed::Job.enqueue(sync_job)
  end
end
