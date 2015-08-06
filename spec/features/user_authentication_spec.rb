require "rails_helper"

feature 'User authentication' do
  scenario "existing user signs in" do
    token = "usergithubtoken"
    user = create(:user)
    stub_repos_requests(token)

    sign_in_as(user, token)

    expect(page).to have_content user.github_username
    expect(analytics).to have_tracked("Signed In").for_user(user)
  end

  scenario "new user signs in" do
    token = "usergithubtoken"
    github_username = "croaky"
    user = build(:user, github_username: github_username)
    stub_repos_requests(token)

    sign_in_as(user, token)

    expect(page).to have_content(github_username)
  end

  scenario 'user signs out' do
    token = "usergithubtoken"
    user = create(:user)
    stub_repos_requests(token)

    sign_in_as(user, token)
    find('a[href="/sign_out"]').click

    expect(page).not_to have_content user.github_username
  end
end
