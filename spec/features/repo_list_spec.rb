require 'spec_helper'

feature 'Repo list' do
  scenario 'user views list', js: true do
    repo = create(:repo, name: 'My Repo')
    sign_in_as(repo.user)

    visit root_path

    expect(page).to have_content 'My Repo'
  end

  scenario 'user syncs repos', js: true do
    user = create(:user, github_token: 'token')
    stub_repo_requests(user.github_token)
    sign_in_as(user)

    visit root_path
    click_link 'Sync repos'

    expect(page).to have_content 'my_private_repo'
  end

  scenario 'user activates repo', js: true do
    repo = create(:repo)
    sign_in_as(repo.user)
    stub_hook_creation_request(
      repo.user.github_token,
      repo.full_github_name,
      URI.join(current_url, "builds?token=#{repo.user.github_token}").to_s
    )

    visit root_path
    click_link 'activate'

    expect(page).to have_link('deactivate')

    visit current_path

    expect(page).to have_link('deactivate')
  end

  scenario 'user deactivates repo', js: true do
    repo = create(:repo, active: true)
    sign_in_as(repo.user)

    visit root_path
    click_link 'deactivate'

    expect(page).to have_link('activate')

    visit current_path

    expect(page).to have_link('activate')
  end
end
