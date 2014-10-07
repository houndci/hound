class RepoSerializer < ActiveModel::Serializer
  attributes(
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
end
