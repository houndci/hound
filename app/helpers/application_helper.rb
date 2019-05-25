module ApplicationHelper
  def avatar_url(user)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    "https://www.gravatar.com/avatar/#{gravatar_id}"
  end

  def display_onboarding?
    !current_user.has_active_repos? || current_user.builds.none?
  end

  def new_window_options(options = {})
    options.merge(target: "_blank", rel: "noopener noreferrer")
  end
end
