class RepoSynchronizationJob < ApplicationJob
  sidekiq_options queue: :high

  def perform(user_id)
    user = User.find(user_id)
    synchronization = RepoSynchronization.new(user)
    synchronization.start
    user.update(refreshing_repos: false)
  end
end
