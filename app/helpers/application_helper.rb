module ApplicationHelper
  def avatar_url(user)
    "https://github.com/#{user.username}.png?size=64"
  end

  def display_onboarding?
    !current_user.has_active_repos? || current_user.builds.none?
  end

  def new_window_options(options = {})
    options.merge(target: "_blank", rel: "noopener noreferrer")
  end

  def svg(file_name, options = {})
    if options[:title].present?
      options[:aria] = true
    else
      options[:aria_hidden] = true
    end

    inline_svg_tag(file_name, options)
  end
end
