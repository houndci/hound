class RepoSerializer < ActiveModel::Serializer
  attributes(
    :admin,
    :active,
    :full_github_name,
    :full_plan_name,
    :github_id,
    :id,
    :in_organization,
    :price_in_cents,
    :private,
    :stripe_subscription_id,
  )

  def price_in_cents
    object.plan_price * 100
  end

  def full_plan_name
    "#{object.plan_type} repo".titleize
  end

  def admin
    has_admin_membership? || has_subscription?
  end

  private

  def membership
    @membership ||= object.memberships.find_by(user_id: current_user.id)
  end

  def has_admin_membership?
    membership.present? && membership.admin?
  end

  def has_subscription?
    current_user.subscribed_repos.include?(object)
  end
end
