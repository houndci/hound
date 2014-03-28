require 'spec_helper'

feature 'User authentication' do
  scenario 'user signs in' do
    user = create(:user)
    stub_repo_requests(user.github_token)

    sign_in_as(user)

    expect(page).to have_content user.github_username
  end

  scenario 'user signs out' do
    user = create(:user)
    stub_repo_requests(user.github_token)
    sign_in_as(user)

    find('a[href="/sign_out"]').click

    expect(page).not_to have_content user.github_username
  end
end
