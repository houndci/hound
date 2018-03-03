# frozen_string_literal: true

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
        revenue: lost_revenue,
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

  private

  attr_reader :user

  def track(options)
    backend.track({
      active_repos_count: user.repos.active.count,
      user_id: user.id,
    }.merge(options))
  end

  def lost_revenue
    if user.current_plan == user.next_plan
      0
    else
      user.current_plan_price - user.next_plan_price
    end
  end
end
