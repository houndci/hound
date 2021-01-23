class Analytics
  class_attribute :backend
  self.backend = AnalyticsRuby

  def initialize(user, params = {})
    @user = user
  end

  def track_signed_in
    track(event: "Signed In")
  end

  def track_repo_activation_failed(repo)
    track(
      event: "Repo Activation Failed",
      properties: {
        name: repo.name,
        private: repo.private
      }
    )
  end

  def track_repo_deactivated(repo)
    track(
      event: "Repo Deactivated",
      properties: {
        name: repo.name,
        private: repo.private,
      }
    )
  end

  def track_build_started(repo)
    track(
      event: "Build Started",
      properties: {
        name: repo.name,
        private: repo.private,
      }
    )
  end

  def track_build_completed(repo)
    track(
      event: "Build Completed",
      properties: {
        name: repo.name,
        private: repo.private,
      }
    )
  end

  def track_purchase(stripe_subscription)
    track(
      event: "Purchase",
      properties: {
        subscription: stripe_subscription.id,
      },
    )
  end

  private

  attr_reader :user

  def track(options)
    backend.track({
      active_repos_count: user.repos.active.count,
      user_id: user.id,
    }.merge(options))
  end
end
