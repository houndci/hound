class Analytics
  class_attribute :backend
  self.backend = AnalyticsRuby

  def initialize(user, params = {})
    @user = user
    @params = params
  end

  def track_signed_up
    track(event: "Signed Up", context: { campaign: campaign_params })
  end

  def track_signed_in
    track(event: "Signed In")
  end

  def track_activated(repo)
    track(event: "Activated Public Repo", properties: repo_properties(repo))
  end

  def track_deactivated(repo)
    track(event: "Deactivated Public Repo", properties: repo_properties(repo))
  end

  def track_reviewed(repo)
    track(event: "Reviewed Repo", properties: repo_properties(repo))
  end

  def track_subscribed(repo)
    track(event: "Subscribed Private Repo", properties: repo_properties(repo))
  end

  def track_unsubscribed(repo)
    track(event: "Unsubscribed Private Repo", properties: repo_properties(repo))
  end

  private

  def track(options)
    backend.track({
      active_repos_count: user.repos.active.count,
      user_id: user.id,
    }.merge(options))
  end

  def campaign_params
    {
      medium: params[:utm_medium],
      name: params[:utm_campaign],
      source: params[:utm_source],
    }.reject { |_, value| value.blank? }
  end

  def repo_properties(repo)
    { name: repo.full_github_name, revenue: repo.price }
  end

  attr_reader :params, :user
end
