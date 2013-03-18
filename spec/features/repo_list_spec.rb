require 'spec_helper'

feature 'Repo list' do
  scenario 'user views list' do
    sign_in_and_stub_github_requests

    expect(page).to have_content 'my_private_repo'
  end

  scenario 'user activates repo', js: true do
    sign_in_and_stub_github_requests

    click_link 'on'

    expect(page).to have_link('off')
  end

  scenario 'user deactivates repo', js: true do
    auth_token = 'authtoken'
    stub_hook_removal_request(auth_token, 'jimtom/My-Private-Repo', 1)
    sign_in_and_stub_github_requests

    click_link 'on'
    click_link 'off'

    expect(page).to have_link('on')
  end

  scenario 'user activates repo then refreshes the page', js: true do
    sign_in_and_stub_github_requests

    click_link 'on'
    reload

    expect(page).to have_link('off')
  end

  def sign_in_and_stub_github_requests
    auth_token = 'authtoken'
    stub_repos_request(auth_token)
    stub_hook_request('jimtom/My-Private-Repo', auth_token)
    sign_in(auth_token)
  end

  def sign_in(auth_token)
    stub_oauth('jimtom', auth_token)
    visit root_path
    click_link 'Sign in'
  end

  def stub_hook_request(full_repo_name, auth_token)
    stub_request(
      :post,
      "https://api.github.com/repos/#{full_repo_name}/hooks"
    ).with(
      headers: { 'Authorization' => "token #{auth_token}" }
    ).to_return(
      status: 200,
      body: '',
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def reload
    visit current_url
  end
end
