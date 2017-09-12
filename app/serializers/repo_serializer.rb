class RepoSerializer < ActiveModel::Serializer
  attributes(
    :admin,
    :active,
    :name,
    :github_id,
    :id,
    :in_organization,
    :owner,
    :price_in_cents,
    :private,
    :stripe_subscription_id,
  )

  def price_in_cents
    if object.public? || owner.whitelisted?
      0
    else
      scope.next_plan_price * 100
    end
  end

  def admin
    has_admin_membership? || has_subscription?
  end

  private

  def membership
    @membership ||= object.memberships.detect { |m| m.user_id == scope.id }
  end

  def has_admin_membership?
    membership.present? && membership.admin?
  end

  def has_subscription?
    object.subscription&.user_id == scope.id
  end
end
