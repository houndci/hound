class RepoSynchronizationJob < Struct.new(:user_id)
  def perform
    user = User.find(user_id)
    synchronization = RepoSynchronization.new(user)
    synchronization.start
  end
end
