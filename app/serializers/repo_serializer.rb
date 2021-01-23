class RepoSerializer < ActiveModel::Serializer
  attributes(
    :admin,
    :active,
    :name,
    :github_id,
    :id,
    :owner,
    :private,
    :stripe_subscription_id,
  )

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
