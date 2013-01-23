module SigninHelper
  def sign_in(username = 'jimtom', auth_token = 'authtoken')
    user = User.create(github_username: username, github_token: auth_token)
    session[:remember_token] = user.remember_token
  end
end
