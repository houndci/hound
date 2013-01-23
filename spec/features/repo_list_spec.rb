require 'spec_helper'

feature 'Repo list' do
  scenario 'user views list' do
    sign_in_and_stub_repos_request

    expect(page).to have_content 'my_private_repo'
  end

  scenario 'user activates repo', js: true do
    sign_in_and_stub_repos_request

    click_link 'on'

    expect(page).to have_link 'off'
  end

  scenario 'user deactivates repo', js: true do
    sign_in_and_stub_repos_request

    click_link 'on'
    click_link 'off'

    expect(page).to have_link 'on'
  end

  scenario 'user activates repo then refreshes the page', js: true do
    sign_in_and_stub_repos_request

    click_link 'on'
    reload

    expect(page).to have_link 'off'
  end

  def sign_in_and_stub_repos_request
    auth_token = 'authtoken'
    stub_oauth('jimtom', auth_token)
    stub_repos_request(auth_token)

    visit root_path
    click_link 'Sign in'
  end

  def reload
    visit current_url
  end
end
