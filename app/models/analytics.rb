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
        name: repo.full_github_name,
        private: repo.private
      }
    )
  end

  def track_repo_activated(repo)
    track(
      event: "Repo Activated",
      properties: {
        name: repo.full_github_name,
        private: repo.private,
        revenue: repo.plan_price,
      }
    )
  end

  def track_repo_deactivated(repo)
    track(
      event: "Repo Deactivated",
      properties: {
        name: repo.full_github_name,
        private: repo.private,
        revenue: -repo.plan_price,
      }
    )
  end

  def track_build_started(repo)
    track(
      event: "Build Started",
      properties: {
        name: repo.full_github_name,
        private: repo.private,
      }
    )
  end

  def track_build_completed(repo)
    track(
      event: "Build Completed",
      properties: {
        name: repo.full_github_name,
        private: repo.private,
      }
    )
  end

  def track_show_cop_names
    track(
      event: "Using ShowCopNames",
      properties: {
        owner: user
      }
    )
  end

  private

  def track(options)
    backend.track({
      active_repos_count: user.repos.active.count,
      user_id: user.id,
    }.merge(options))
  end

  attr_reader :user
end
