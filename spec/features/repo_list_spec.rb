require 'spec_helper'

feature 'Repo list' do
  scenario 'user views list', js: true do
    user = create(:user)
    repo = create(:repo, full_github_name: 'thoughtbot/my-repo')
    repo.users << user
    sign_in_as(user)

    visit root_path

    expect(page).to have_content 'thoughtbot/my-repo'
  end

  scenario 'user syncs repos', js: true do
    user = create(:user)
    stub_repo_requests(AuthenticationHelper::GITHUB_TOKEN)
    sign_in_as(user)

    visit root_path
    click_link I18n.t('sync_repos')

    expect(page).to have_content I18n.t('syncing_repos')
    expect(page).not_to have_content 'jimtom/My-Private-Repo'
  end

  scenario 'user activates repo', js: true do
    pending

    user = create(:user)
    repo = create(:repo)
    repo.users << user
    hook_url = "http://#{ENV['HOST']}/builds"
    stub_repo_request(repo.full_github_name)
    stub_add_collaborator_request(repo.full_github_name)
    stub_hook_creation_request(repo.full_github_name, hook_url)

    sign_in_as(user)
    visit root_path
    find('.activate').click

    expect(page).to have_css('.deactivate')

    visit current_url

    expect(page).to have_css('.deactivate')
  end

  scenario 'user deactivates repo', js: true do
    user = create(:user)
    repo = create(:active_repo)
    repo.users << user
    stub_hook_removal_request(repo.full_github_name, repo.hook_id)

    sign_in_as(user)
    visit root_path
    find('.deactivate').click

    expect(page).to have_css('.activate')

    visit current_path

    expect(page).to have_css('.activate')
  end
end
