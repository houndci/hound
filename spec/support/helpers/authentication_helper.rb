module AuthenticationHelper
  def stub_sign_in(user)
    user.update(token: "letmein")
    session[:remember_token] = user.remember_token
  end

  def sign_in_as(user, token = "letmein")
    stub_oauth(username: user.username, email: user.email, token: token)
    allow(User).to receive(:find_by).and_return(user)

    visit root_path
    find("[role=navigation]").click_on I18n.t("authenticate")
  end
end
