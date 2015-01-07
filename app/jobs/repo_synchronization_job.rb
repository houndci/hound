class RepoSynchronizationJob < ActiveJob::Base
  class AlreadyRefresing < StandardError; end
  extend Retryable

  queue_as :high

  before_perform do |job|
    unless User.set_refreshing_repos(job.arguments.first)
      raise AlreadyRefresing
    end
  end

  def perform(user_id, github_token)
    user = User.find(user_id)
    synchronization = RepoSynchronization.new(user, github_token)
    synchronization.start
    user.update_attribute(:refreshing_repos, false)
  rescue Resque::TermException
    retry_job
  end

  rescue_from(AlreadyRefresing) do |_e|
  end
end
