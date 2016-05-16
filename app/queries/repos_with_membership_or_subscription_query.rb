class ReposWithMembershipOrSubscriptionQuery
  def initialize(user)
    @user = user
  end

  def run
    @user.subscribed_repos.includes(:subscription) |
      @user.repos_by_activation_ability.includes(:subscription)
  end
end
