require 'spec_helper'

feature 'Repo list' do
  scenario 'user views list' do
    user = create(:user)
    repo = create(:repo, user: user, name: 'My Repo')
    sign_in_as(user)

    visit repos_path

    expect(page).to have_content 'My Repo'
  end

  scenario 'user syncs repos' do
    user = create(:user, github_token: 'token')
    stub_repo_requests(user.github_token)
    sign_in_as(user)

    visit repos_path
    click_link 'Sync repos'

    expect(page).to have_content 'my_private_repo'
  end

  scenario 'user activates repo' do
    user = create(:user, github_token: 'token')
    repo = create(:repo, user: user, name: 'My Repo')
    sign_in_as(user)
    stub_hook_creation_request(
      user.github_token,
      repo.full_github_name,
      URI.join(current_url, "builds?token=#{user.github_token}").to_s
    )

    click_link 'edit'
    check 'Active'
    click_button 'Update Repo'

    expect(page).to have_content('active')
  end

  scenario 'user deactivates repo' do
    user = create(:user, github_token: 'token')
    repo = create(:repo, user: user, name: 'My Repo', active: true)
    sign_in_as(user)

    click_link 'edit'
    uncheck 'Active'
    click_button 'Update Repo'

    expect(page).not_to have_content('active')
  end
end
