require 'spec_helper'

feature 'User authentication' do
  scenario 'user signs in' do
    user = create(:user)

    sign_in_as(user)

    expect(page).to have_link 'Sign out'
    expect(page).to have_content user.github_username
  end

  scenario 'user signs out' do
    user = create(:user)
    sign_in_as(user)

    click_link 'Sign out'

    expect(page).to have_link 'Sign in'
    expect(page).not_to have_content user.github_username
  end
end
