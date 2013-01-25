module AuthenticationHelper
  def stub_sign_in(user = FactoryGirl.create(:user))
    session[:remember_token] = user.remember_token
  end
end
