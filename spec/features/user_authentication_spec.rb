require 'spec_helper'

feature 'User authentication' do
  scenario 'user signs in' do
    stub_oauth('jimtom', 'authtoken')
    stub_repos_request('authtoken')

    visit root_path
    click_link 'Sign in'

    expect(page).to have_link 'Sign out'
    expect(page).to have_content 'jimtom'
  end

  scenario 'user signs out' do
    stub_oauth
    stub_repos_request

    visit root_path
    click_link 'Sign in'
    click_link 'Sign out'

    expect(page).to have_link 'Sign in'
  end
end
