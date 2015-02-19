module ApplicationHelper
  def avatar_url(user)
    gravatar_id = Digest::MD5::hexdigest(user.email_address.downcase)
    "https://www.gravatar.com/avatar/#{gravatar_id}"
  end
end
