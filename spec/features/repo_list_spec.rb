# frozen_string_literal: true

require "rails_helper"

feature "Repo list", js: true do
  let(:username) { ENV.fetch("HOUND_GITHUB_USERNAME") }
  let(:user) { create(:user, token_scopes: "public_repo,user:email") }

  scenario "user views list of repos" do
    user = create(:user, token_scopes: "public_repo,user:email")
    org = create(:owner, name: "thoughtbot")
    restricted_repo = create(:repo, name: "#{user.username}/inaccessible-repo")
    activatable_repo = create(:repo, owner: org, name: "#{org.name}/my-repo")
    create(:membership, repo: activatable_repo, user: user, admin: true)
    create(:membership, repo: restricted_repo, user: user, admin: false)

    sign_in_as(user)

    within "[data-org-name=#{org.name}]" do
      expect(page).to have_text activatable_repo.name
      expect(page).to have_css ".repo-toggle"
    end
    within "[data-org-name=#{restricted_repo.owner.name}]" do
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

    sign_in_as(user, token)

    expect(page).to have_content(repo.name)

    click_button I18n.t("sync_repos")

    expect(page).to have_text("TEST_GITHUB_LOGIN/TEST_GITHUB_REPO_NAME")
    expect(page).not_to have_text(repo.name)
  end

  scenario "user signs up" do
    sign_in_as(user)

    expect(page).to have_content I18n.t("sign_out")
  end

  scenario "user activates repo" do
    token = "letmein"

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
    create_repo(:active)

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
    create_repo(:active, private: true)

    sign_in_as(user, token)
    find(".repos .repo-toggle").click

    expect(page).not_to have_css(".repo--active")
    expect(user.repos.active.count).to eq(0)

    visit current_path

    expect(user.repos.active.count).to eq(0)
  end

  scenario "user enables organization-wide config" do
    owner = create(:owner, github_id: 1, name: "test")
    create(:repo, owner: owner, users: [user], name: "test/abc")
    repo = create(:repo, owner: owner, users: [user], name: "test/def")

    sign_in_as(user)
    find(".toggle-switch").click
    wait_for_ajax
    select_config_repo(repo.name)
    find(".organization-header-select").select(repo.name)

    expect(page).to have_css("[data-role='config-saved']")
    expect(owner.reload).to have_attributes(
      config_enabled?: true,
      config_repo: repo.name,
    )
  end

  def create_repo(*options)
    repo = create(:repo, *options)
    create(:membership, repo: repo, user: user, admin: true)

    repo
  end

  def select_config_repo(repo_name)
    find(".organization-header-select").select(repo_name)
  end
end
