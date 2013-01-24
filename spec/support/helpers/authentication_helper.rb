module AuthenticationHelper
  def stub_sign_in(user = create(:user))
    session[:remember_token] = user.remember_token
  end
end
