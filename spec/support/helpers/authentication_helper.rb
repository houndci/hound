module AuthenticationHelper
  def stub_sign_in(user = create(:user))
    session[:remember_token] = user.remember_token
  end

  def sign_in_as(user)
    stub_oauth(user.github_username, user.github_token)
    visit root_path
    click_link 'Sign in'
  end
end
