module AuthenticationHelper
  def stub_sign_in(user)
    user.update(token: "letmein")
    session[:remember_token] = user.remember_token
  end

  def sign_in_as(user, token = "letmein")
    stub_oauth(
      username: user.github_username,
      email: user.email_address,
      token: token
    )
    stub_scopes_request(token: token)
    visit root_path(SPLIT_DISABLE: "true")
    click_link(I18n.t('authenticate'), match: :first)
  end
end
