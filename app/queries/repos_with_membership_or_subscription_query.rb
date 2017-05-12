class ReposWithMembershipOrSubscriptionQuery
  static_facade :call

  def initialize(user)
    @user = user
  end

  def call
    subscribed_repos | activatable_repos
  end

  private

  def subscribed_repos
    @user.subscribed_repos.includes(*repo_includes)
  end

  def activatable_repos
    @user.repos_by_activation_ability.includes(*repo_includes)
  end

  def repo_includes
    [
      :memberships,
      :owner,
      :subscription,
    ]
  end
end
