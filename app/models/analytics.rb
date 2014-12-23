class Analytics
  class_attribute :backend
  self.backend = AnalyticsRuby

  def initialize(user, params = {})
    @user = user
  end

  def track_signed_in
    track(event: "Signed In")
  end

  def track_enabled(repo)
    track(
      event: "Enabled Public Repo",
      properties: {
        name: repo.full_github_name
      }
    )
  end

  def track_disabled(repo)
    track(
      event: "Disabled Public Repo",
      properties: {
        name: repo.full_github_name
      }
    )
  end

  def track_reviewed(repo)
    track(
      event: "Reviewed Repo",
      properties: {
        name: repo.full_github_name
      }
    )
  end

  def track_subscribed(repo)
    track(
      event: "Subscribed Private Repo",
      properties: {
        name: repo.full_github_name,
        revenue: repo.plan_price
      }
    )
  end

  def track_unsubscribed(repo)
    track(
      event: "Unsubscribed Private Repo",
      properties: {
        name: repo.full_github_name,
        revenue: -repo.plan_price
      }
    )
  end

  private

  def track(options)
    backend.track({
      enabled_repos_count: user.repos.enabled.count,
      user_id: user.id,
    }.merge(options))
  end

  attr_reader :user
end
