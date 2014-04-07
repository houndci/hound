require 'spec_helper'

feature 'Repo list', js: true do
  scenario 'user views list' do
    user = create(:user)
    repo = create(:repo, full_github_name: 'thoughtbot/my-repo')
    repo.users << user
    sign_in_as(user)

    visit root_path

    expect(page).to have_content 'thoughtbot/my-repo'
  end

  scenario 'user syncs repos' do
    user = create(:user)
    repo = create(:repo)
    user.repos << repo
    stub_repo_requests(AuthenticationHelper::GITHUB_TOKEN)
    sign_in_as(user)

    visit root_path

    expect(page).to have_content(repo.full_github_name)

    click_link I18n.t('sync_repos')

    expect(page).to have_content I18n.t('syncing_repos').upcase
    expect(page).not_to have_content 'jimtom/My-Private-Repo'
  end

  scenario 'user signs up' do
    with_job_delay do
      user = create(:user)

      sign_in_as(user)

      expect(page).to have_content I18n.t('syncing_repos').upcase
    end
  end

  scenario 'user activates repo' do
    user = create(:user)
    repo = create(:repo)
    repo.users << user
    hook_url = "http://#{ENV['HOST']}/builds"
    stub_repo_request(repo.full_github_name)
    stub_add_collaborator_request(repo.full_github_name)
    stub_hook_creation_request(repo.full_github_name, hook_url)

    sign_in_as(user)
    find('.toggle').click

    expect(page).to have_css('.active')
    expect(page).to have_content '1 OF 1'

    visit root_path

    expect(page).to have_css('.active')
    expect(page).to have_content '1 OF 1'
  end

  scenario 'user deactivates repo' do
    user = create(:user)
    repo = create(:repo, :active)
    repo.users << user
    stub_hook_removal_request(repo.full_github_name, repo.hook_id)

    sign_in_as(user)
    visit root_path
    find('.toggle').click

    expect(page).not_to have_css('.active')
    expect(page).to have_content '0 OF 1'

    visit current_path

    expect(page).not_to have_css('.active')
    expect(page).to have_content '0 OF 1'
  end

  private

  def with_job_delay
    Delayed::Worker.delay_jobs = true
    yield
  ensure
    Delayed::Worker.delay_jobs = false
  end
end
