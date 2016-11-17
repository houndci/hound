require "rails_helper"

feature "Repo list", js: true do
  let(:username) { ENV.fetch("HOUND_GITHUB_USERNAME") }
  let(:user) { create(:user, token_scopes: "public_repo,user:email") }

  scenario "user views list of repos" do
    user = create(:user, token_scopes: "public_repo,user:email")
    restricted_repo = create(
      :repo,
      name: "#{user.username}/inaccessible-repo",
    )
    organization = "thoughtbot"
    activatable_repo = create(:repo, name: "#{organization}/my-repo")
    create(:membership, repo: activatable_repo, user: user, admin: true)
    create(:membership, repo: restricted_repo, user: user, admin: false)

    sign_in_as(user)

    within "[data-org-name=#{organization}]" do
      expect(page).to have_text activatable_repo.name
      expect(page).to have_css ".repo-toggle"
    end
    within "[data-org-name=#{user.username}]" do
      expect(page).to have_text restricted_repo.name
      expect(page).to have_text I18n.t("cannot_activate_repo")
      expect(page).not_to have_css ".repo-toggle"
    end
  end

  scenario "signed out user views repo list" do
    repo = create(:repo, name: "thoughtbot/my-repo")
    repo.users << user

    expect(page).not_to have_content repo.name
  end

  scenario "user sees onboarding" do
    token = "letmein"
    stub_repos_requests(token)

    sign_in_as(user)

    expect(page).to have_content I18n.t("onboarding.title")
  end

  scenario "user does not see onboarding" do
    build = create(:build)
    build.repo.users << user

    sign_in_as(user)

    expect(page).to_not have_content I18n.t("onboarding.title")
  end

  scenario "user filters list" do
    repo1 = create_repo(name: "#{user.username}/foo")
    repo2 = create_repo(name: "#{user.username}/bar")

    sign_in_as(user)
    find(".repo-search-tools-input").set("fo")

    expect(page).to have_text repo1.name
    expect(page).not_to have_text repo2.name
  end

  scenario "user syncs repos" do
    token = "letmein"
    repo = create_repo(name: "user1/test-repo")
    stub_repos_requests(token)

    sign_in_as(user, token)

    expect(page).to have_content(repo.name)

    click_button I18n.t("sync_repos")

    expect(page).to have_text("jimtom/My-Private-Repo")
    expect(page).not_to have_text(repo.name)
  end

  scenario "user signs up" do
    token = "letmein"

    stub_repos_requests(token)
    sign_in_as(user)

    expect(page).to have_content I18n.t("sign_out")
  end

  scenario "user activates repo" do
    token = "letmein"
    repo = create_repo(private: false)
    hook_url = "http://#{ENV["HOST"]}/builds"
    stub_repo_request(repo.name, token)
    stub_add_collaborator_request(username, repo.name, token)
    stub_hook_creation_request(repo.name, hook_url, token)

    sign_in_as(user, token)
    find(".repo .repo-toggle").click

    expect(page).to have_css(".repo--active")
    expect(user.repos.active.count).to eq(1)

    visit repos_path

    expect(page).to have_css(".repo--active")
    expect(user.repos.active.count).to eq(1)
  end

  scenario "user with admin access activates organization repo" do
    token = "letmein"
    repo = create_repo(private: false, name: "testing/repo")
    hook_url = "http://#{ENV["HOST"]}/builds"
    stub_repo_with_org_request(repo.name, token)
    stub_hook_creation_request(repo.name, hook_url, token)

    sign_in_as(user, token)
    find(".repos .repo-toggle").click

    expect(page).to have_css(".repo--active")
    expect(user.repos.active.count).to eq(1)

    visit repos_path

    expect(page).to have_css(".repo--active")
    expect(user.repos.active.count).to eq(1)
  end

  scenario "user deactivates repo" do
    token = "letmein"
    repo = create_repo(:active)
    stub_repo_request(repo.name, token)
    stub_hook_removal_request(repo.name, repo.hook_id)
    stub_remove_collaborator_request(username, repo.name, token)

    sign_in_as(user, token)
    find(".repos .repo-toggle").click

    expect(page).not_to have_css(".repo--active")
    expect(user.repos.active.count).to eq(0)

    visit current_path

    expect(page).not_to have_css(".repo--active")
    expect(user.repos.active.count).to eq(0)
  end

  scenario "user deactivates private repo without subscription" do
    token = "letmein"
    repo = create_repo(:active, private: true)
    stub_repo_request(repo.name, token)
    stub_hook_removal_request(repo.name, repo.hook_id)
    stub_remove_collaborator_request(username, repo.name, token)

    sign_in_as(user, token)
    find(".repos .repo-toggle").click

    expect(page).not_to have_css(".repo--active")
    expect(user.repos.active.count).to eq(0)

    visit current_path

    expect(user.repos.active.count).to eq(0)
  end

  def create_repo(*options)
    repo = create(:repo, *options)
    create(:membership, repo: repo, user: user, admin: true)

    repo
  end
end
