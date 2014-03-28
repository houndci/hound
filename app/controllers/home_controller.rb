class HomeController < ApplicationController
  def index
    if current_user.repos.count == 0
      sync_job = RepoSynchronizationJob.new(current_user.id)
      Delayed::Job.enqueue(sync_job)
    end
  end
end
