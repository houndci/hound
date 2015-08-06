class RepoSynchronizationJob < ApplicationJob
  queue_as :high

  def perform(user)
    synchronization = RepoSynchronization.new(user)
    synchronization.start
    user.update_attribute(:refreshing_repos, false)
  end
end
