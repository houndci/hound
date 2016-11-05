class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :card_exists, :refreshing_repos

  def card_exists
    object.stripe_customer_id.present?
  end
end
