class RepoSynchronizationJob
  extend Retryable

  @queue = :high

  def self.before_enqueue(user_id, github_token)
    User.set_refreshing_repos(user_id)
  end

  def self.perform(user_id, github_token)
    user = User.find(user_id)
    synchronization = RepoSynchronization.new(user, github_token)
    synchronization.start
    user.update_attribute(:refreshing_repos, false)
  rescue Resque::TermException
    Resque.enqueue(self, user_id, github_token)
  end
end
