module AuthenticationHelper
  def stub_sign_in(user, token = hound_token)
    session[:remember_token] = user.remember_token
    session[:github_token] = token
  end

  def sign_in_as(user, token = hound_token)
    stub_oauth(
      username: user.github_username,
      email: user.email_address,
      token: token
    )
    visit root_path
    click_link(I18n.t('authenticate'), match: :first)
  end
end
