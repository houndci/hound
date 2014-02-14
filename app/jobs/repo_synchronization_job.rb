class RepoSynchronizationJob
  def initialize(user_id, monitor = Raven)
    @user_id = user_id
    @monitor = monitor
  end

  def perform
    user = User.find(user_id)
    synchronization = RepoSynchronization.new(user)
    synchronization.start
  end

  def error(job, exception)
    monitor.capture_exception(exception)
  end

  private

  attr_reader :user_id, :monitor
end
