module AuthenticationHelper
  def stub_sign_in(user = User.create(github_username: 'jimtom'))
    session[:remember_token] = user.remember_token
  end
end
