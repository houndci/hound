require "rails_helper"

feature 'User authentication' do
  scenario "existing user signs in" do
    token = "usergithubtoken"
    user = create(:user)

    sign_in_as(user, token)

    expect(page).to have_content user.username
    expect(analytics).to have_tracked("Signed In").for_user(user)
  end

  scenario "new user signs in" do
    token = "usergithubtoken"
    username = "croaky"
    user = build(:user, username: username)

    sign_in_as(user, token)

    expect(page).to have_content(username)
  end

  scenario 'user signs out' do
    token = "usergithubtoken"
    user = create(:user)

    sign_in_as(user, token)
    find('a[href="/sign_out"]').click

    expect(page).not_to have_content user.username
  end
end
