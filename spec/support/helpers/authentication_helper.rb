module AuthenticationHelper
  GITHUB_TOKEN = 'githubtoken'

  def stub_sign_in(user = create(:user))
    session[:remember_token] = user.remember_token
    session[:github_token] = GITHUB_TOKEN
  end

  def sign_in_as(user)
    stub_oauth(user.github_username, user.github_token)
    visit root_path
    click_link I18n.t('authenticate')
  end
end
