module SigninHelper
  def sign_in(username = 'jimtom')
    user = User.create(github_username: username)
    session[:remember_token] = user.remember_token
  end
end
