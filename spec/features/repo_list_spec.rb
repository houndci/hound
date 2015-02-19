require "spec_helper"

feature "Repo list", js: true do
  let(:username) { 'houndci' }

  scenario "user views landing page" do
    user = create(:user)
    repo = create(:repo, full_github_name: "thoughtbot/my-repo")
    repo.users << user
    sign_in_as(user)

    visit root_path

    expect(page).to have_content repo.full_github_name
  end

  scenario "user views list" do
    user = create(:user)
    repo = create(:repo, full_github_name: "thoughtbot/my-repo")
    repo.users << user
    sign_in_as(user)

    visit repos_path

    expect(page).to have_content repo.full_github_name
  end

  scenario "user filters list" do
    user = create(:user)
    repo = create(:repo, full_github_name: "thoughtbot/my-repo")
    repo.users << user

    sign_in_as(user)
    visit repos_path
    find(".search").set(repo.full_github_name)

    expect(page).to have_content repo.full_github_name
  end

  scenario "user syncs repos" do
    token = "usergithubtoken"
    user = create(:user)
    repo = create(:repo, full_github_name: "user1/test-repo")
    user.repos << repo
    stub_repo_requests(token)

    sign_in_as(user, token)
    visit repos_path

    expect(page).to have_content(repo.full_github_name)

    click_link I18n.t("sync_repos")

    expect(page).to have_text("jimtom/My-Private-Repo")
    expect(page).not_to have_text(repo.full_github_name)
  end

  scenario "user signs up" do
    with_job_delay do
      user = create(:user)

      sign_in_as(user)

      expect(page).to have_content I18n.t("syncing_repos")
    end
  end

  scenario "user activates repo" do
    token = "usergithubtoken"
    user = create(:user)
    repo = create(:repo, private: false)
    repo.users << user
    hook_url = "http://#{ENV["HOST"]}/builds"
    stub_repo_request(repo.full_github_name, token)
    stub_add_collaborator_request(username, repo.full_github_name, token)
    stub_hook_creation_request(repo.full_github_name, hook_url, token)
    stub_memberships_request
    stub_membership_update_request

    sign_in_as(user, token)
    find("li.repo .toggle").click

    expect(page).to have_css(".active")
    expect(page).to have_content "1 OF 1"

    visit repos_path

    expect(page).to have_css(".active")
    expect(page).to have_content "1 OF 1"
  end

  scenario "user with admin access activates organization repo" do
    user = create(:user)
    repo = create(:repo, private: false, full_github_name: "testing/repo")
    repo.users << user
    hook_url = "http://#{ENV["HOST"]}/builds"
    team_id = 4567 # from fixture
    token = "usergithubtoken"
    stub_repo_with_org_request(repo.full_github_name, token)
    stub_hook_creation_request(repo.full_github_name, hook_url, token)
    stub_repo_teams_request(repo.full_github_name, token)
    stub_user_teams_request(token)
    stub_add_user_to_team_request(team_id, username, token)
    stub_memberships_request
    stub_membership_update_request

    sign_in_as(user, token)
    find(".repos .toggle").click

    expect(page).to have_css(".active")
    expect(page).to have_content "1 OF 1"

    visit repos_path

    expect(page).to have_css(".active")
    expect(page).to have_content "1 OF 1"
  end

  scenario "user deactivates repo" do
    token = "usergithubtoken"
    user = create(:user)
    repo = create(:repo, :active)
    repo.users << user
    stub_repo_request(repo.full_github_name, token)
    stub_hook_removal_request(repo.full_github_name, repo.hook_id)
    stub_remove_collaborator_request(username, repo.full_github_name, token)

    sign_in_as(user, token)
    visit repos_path
    find(".repos .toggle").click

    expect(page).not_to have_css(".active")
    expect(page).to have_content "0 OF 1"

    visit current_path

    expect(page).not_to have_css(".active")
    expect(page).to have_content "0 OF 1"
  end

  scenario "user deactivates private repo without subscription" do
    token = "usergithubtoken"
    user = create(:user)
    repo = create(:repo, :active, private: true)
    repo.users << user
    stub_repo_request(repo.full_github_name, token)
    stub_hook_removal_request(repo.full_github_name, repo.hook_id)
    stub_remove_collaborator_request(username, repo.full_github_name, token)

    sign_in_as(user, token)
    visit repos_path
    find(".repos .toggle").click

    expect(page).not_to have_css(".active")
    expect(page).to have_content "0 OF 1"

    visit current_path

    expect(page).not_to have_css(".active")
    expect(page).to have_content "0 OF 1"
  end

  private

  def with_job_delay
    Resque.inline = false
    yield
  ensure
    Resque.inline = true
  end
end
