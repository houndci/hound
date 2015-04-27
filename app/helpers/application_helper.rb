module ApplicationHelper
  def avatar_url(user)
    gravatar_id = Digest::MD5::hexdigest(user.email_address.downcase)
    "https://www.gravatar.com/avatar/#{gravatar_id}"
  end

  def display_onboarding?
    Build.
      joins(repo: :memberships).
      where(memberships: { user_id: current_user.id }).
      empty?
  end
end
