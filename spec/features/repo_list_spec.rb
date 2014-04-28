require 'spec_helper'

feature 'Repo list', js: true do
  scenario 'user views list' do
    user = create(:user)
    repo = create(:repo, full_github_name: 'thoughtbot/my-repo')
    repo.users << user
    stub_user_emails_request(AuthenticationHelper::GITHUB_TOKEN)
    sign_in_as(user)

    visit root_path

    expect(page).to have_content repo.full_github_name
  end

  scenario 'user filters list' do
    user = create(:user)
    repo = create(:repo, full_github_name: 'thoughtbot/my-repo')
    repo.users << user
    stub_user_emails_request(AuthenticationHelper::GITHUB_TOKEN)
    sign_in_as(user)

    visit root_path
    find('.search').set(repo.full_github_name)

    expect(page).to have_content repo.full_github_name
  end

  scenario 'user syncs repos' do
    user = create(:user)
    repo = create(:repo)
    user.repos << repo
    stub_repo_requests(AuthenticationHelper::GITHUB_TOKEN)
    stub_user_emails_request(AuthenticationHelper::GITHUB_TOKEN)
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
    stub_user_emails_request(AuthenticationHelper::GITHUB_TOKEN)

    sign_in_as(user)
    find('.toggle').click

    expect(page).to have_css('.active')
    expect(page).to have_content '1 OF 1'

    visit root_path

    expect(page).to have_css('.active')
    expect(page).to have_content '1 OF 1'
  end

  scenario 'user with admin access activates organization repo' do
    user = create(:user)
    repo = create(:repo, full_github_name: 'testing/repo')
    repo.users << user
    hook_url = "http://#{ENV['HOST']}/builds"
    team_id = 4567 # from fixture
    hound_user = 'houndci'
    stub_repo_with_org_request(repo.full_github_name)
    stub_hook_creation_request(repo.full_github_name, hook_url)
    stub_repo_teams_request(repo.full_github_name)
    stub_user_teams_request
    stub_add_user_to_team_request(hound_user, team_id)
    stub_user_emails_request(AuthenticationHelper::GITHUB_TOKEN)

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
    stub_user_emails_request(AuthenticationHelper::GITHUB_TOKEN)

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
    Resque.inline = false
    yield
  ensure
    Resque.inline = true
  end
end
