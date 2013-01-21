require 'spec_helper'

feature 'Repo list' do
  scenario 'authenticated user views list' do
    auth_token = 'authtoken'
    stub_oauth('jimtom', auth_token)
    stub_repos_request(auth_token)

    visit root_path
    click_link 'Sign in'

    expect(page).to have_content 'my_private_repo'
  end
end
