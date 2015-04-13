class RepoSynchronizationJob < ApplicationJob
  queue_as :high

  def perform(user, github_token)
    synchronization = RepoSynchronization.new(user, github_token)
    synchronization.start
    user.update_attribute(:refreshing_repos, false)
  end
end
