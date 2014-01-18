class ReposController < ApplicationController
  include ActionController::Live

  respond_to :json

  def index
    respond_with current_user.repos.order(:full_github_name)
  end

  def update
    repo = current_user.repos.find(params[:id])

    if params[:active]
      activator.activate(repo)
    else
      activator.deactivate(repo)
    end

    respond_with repo
  end

  def sync
    sync_job = RepoSynchronizationJob.new(current_user.id)
    Delayed::Job.enqueue(sync_job)
    head 200
  end

  def events
    response.headers['Content-Type'] = 'text/event-stream'

    while true do
      sync_jobs = Delayed::Job.uncached do
        Delayed::Job.count_by_sql(<<-SQL)
  select count(*)
  from delayed_jobs
  where handler like '%RepoSynchronizationJob%'
  and handler like '%user_id: #{current_user.id}%'
  and failed_at IS NULL
        SQL
      end

      response.stream.write "data: #{sync_jobs}\n\n"
      sleep 5
    end
  rescue IOError
    puts 'Stream closed'
  ensure
    response.stream.close
  end

  private

  def activator
    RepoActivator.new
  end
end
