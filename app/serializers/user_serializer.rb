class UserSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :refreshing_repos,
    :subscribed_repo_count,
    :plan_max,
    :username,
  )

  def subscribed_repo_count
    object.subscribed_repos.count
  end
end
