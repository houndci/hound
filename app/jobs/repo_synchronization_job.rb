class RepoSynchronizationJob < Struct.new(:user_id, :github_token)
  include Monitorable

  def perform
    user = User.find(user_id)
    synchronization = RepoSynchronization.new(user, github_token)
    synchronization.start
  end
end
