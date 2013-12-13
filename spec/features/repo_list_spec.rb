require 'spec_helper'

feature 'Repo list' do
  scenario 'user views list', js: true do
    user = create(:user)
    repo = create(:repo, full_github_name: 'thoughtbot/my-repo')
    create(:membership, user: user, repo: repo)
    sign_in_as(user)

    visit root_path

    expect(page).to have_content 'thoughtbot/my-repo'
  end

  scenario 'user syncs repos', js: true do
    user = create(:user, github_token: 'token')
    stub_repo_requests(user.github_token)
    sign_in_as(user)

    visit root_path
    click_link I18n.t('sync_repos')

    expect(page).to have_content 'jimtom/My-Private-Repo'
  end

  scenario 'user activates repo', js: true do
    user = create(:user)
    repo = create(:repo)
    create(:membership, user: user, repo: repo)
    sign_in_as(user)
    stub_hook_creation_request(
      repo.github_token,
      repo.full_github_name,
      URI.join("http://#{ENV['HOST']}", "builds?token=#{repo.github_token}").to_s
    )

    visit root_path
    click_link I18n.t('activate_repo')

    expect(page).to have_link('deactivate')

    visit current_url

    expect(page).to have_link('deactivate')
  end

  scenario 'user deactivates repo', js: true do
    user = create(:user)
    repo = create(:active_repo)
    create(:membership, user: user, repo: repo)
    sign_in_as(user)

    visit root_path
    click_link I18n.t('deactivate_repo')

    expect(page).to have_link('activate')

    visit current_path

    expect(page).to have_link('activate')
  end
end
