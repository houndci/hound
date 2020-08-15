module AuthenticationHelper
  def stub_sign_in(user)
    user.update(token: "letmein")
    session[:remember_token] = user.remember_token
    session[:signed_in_with_app] = true
  end

  def sign_in_as(user, token = "letmein")
    stub_oauth(username: user.username, email: user.email, token: token)
    visit root_path
    find(".c-app-nav").click_on I18n.t("authenticate")
    ensure_repos_load_via_ajax
  end

  private

  def ensure_repos_load_via_ajax
    if Capybara.current_driver != :rack_test
      expect(page).to have_css(".organizations")
    end
  end
end
