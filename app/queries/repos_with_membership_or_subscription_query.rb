class ReposWithMembershipOrSubscriptionQuery
  static_facade :call

  def initialize(user)
    @user = user
  end

  def call
    @user.subscribed_repos.includes(:subscription) |
      @user.repos_by_activation_ability.includes(:subscription)
  end
end
