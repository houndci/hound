module AuthenticationHelper
  def stub_sign_in(user)
    user.update(token: "letmein")
    session[:remember_token] = user.remember_token
  end

  def sign_in_as(user, token = "letmein")
    stub_oauth(username: user.username, email: user.email, token: token)
    visit root_path(SPLIT_DISABLE: "true")
    click_link(I18n.t('authenticate'), match: :first)
  end
end
