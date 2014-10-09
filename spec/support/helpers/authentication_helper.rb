module AuthenticationHelper
  GITHUB_TOKEN = 'githubtoken'

  def stub_sign_in(user = create(:user))
    session[:remember_token] = user.remember_token
    session[:github_token] = GITHUB_TOKEN
  end

  def sign_in_as(user, params = {})
    stub_oauth(
      username: user.github_username,
      email: user.email_address,
      token: GITHUB_TOKEN
    )
    visit root_path(params)
    click_link(I18n.t('authenticate'), match: :first)
  end
end
