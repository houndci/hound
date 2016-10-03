class RepoSerializer < ActiveModel::Serializer
  attributes(
    :admin,
    :active,
    :full_github_name,
    :full_plan_name,
    :github_id,
    :id,
    :in_organization,
    :owner,
    :price_in_cents,
    :price_in_dollars,
    :private,
    :stripe_subscription_id
  )

  def price_in_cents
    object.plan_price * 100
  end

  def price_in_dollars
    object.plan_price
  end

  def full_plan_name
    "#{object.plan_type} repo".titleize
  end

  def admin
    has_admin_membership? || has_subscription?
  end

  private

  def membership
    @membership ||= object.memberships.find_by(user_id: scope.id)
  end

  def has_admin_membership?
    membership.present? && membership.admin?
  end

  def has_subscription?
    scope.subscribed_repos.include?(object)
  end
end
