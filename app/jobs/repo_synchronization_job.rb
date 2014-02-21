class RepoSynchronizationJob < Struct.new(:user_id)
  include Monitorable

  def perform
    user = User.find(user_id)
    synchronization = RepoSynchronization.new(user)
    synchronization.start
  end
end
