module ApplicationHelper
  def avatar_url(user)
    gravatar_id = Digest::MD5::hexdigest(user.email_address.downcase)
    "https://www.gravatar.com/avatar/#{gravatar_id}"
  end

  def display_onboarding?
    current_user.repos.select { |repo| repo.builds.count > 0 }.length == 0
  end
end
