require 'spec_helper'

feature 'Repo list' do
  scenario 'authenticated user views list' do
    stub_oauth('jimtom', 'authtoken')
    stub_repos_request

    visit root_path
    click_link 'Sign in'

    expect(page).to have_content 'my_private_repo'
  end
end
