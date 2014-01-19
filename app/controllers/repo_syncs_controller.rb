class RepoSyncsController < ApplicationController
  respond_to :json

  def index
    syncs = Delayed::Job.uncached do
      Delayed::Job.where(<<-SQL)
handler like '%RepoSynchronizationJob%'
and handler like '%user_id: #{current_user.id}%'
and failed_at IS NULL
      SQL
    end

    respond_with syncs
  end

  def create
    sync_job = RepoSynchronizationJob.new(current_user.id)
    Delayed::Job.enqueue(sync_job)
    head 201
  end
end
