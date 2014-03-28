class HomeController < ApplicationController
  def index
    sync_job = RepoSynchronizationJob.new(current_user.id)
    Delayed::Job.enqueue(sync_job)
  end
end
