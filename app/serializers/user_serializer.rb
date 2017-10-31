class UserSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :refreshing_repos,
    :subscribed_repo_count,
    :plan_max,
    :username,
    :owners,
  )

  def card_exists
    object.stripe_customer_id.present?
  end

  def subscribed_repo_count
    object.subscribed_repos.count
  end
end
