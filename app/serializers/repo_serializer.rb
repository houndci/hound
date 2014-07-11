class RepoSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :github_id,
    :active,
    :full_github_name,
    :private,
    :in_organization,
    :price,
    :price_in_cents,
    :full_plan_name
  )

  def price_in_cents
    object.price * 100
  end

  def full_plan_name
    "#{object.plan} repo".titleize
  end
end
