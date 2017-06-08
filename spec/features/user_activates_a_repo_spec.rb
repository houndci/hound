require "rails_helper"

RSpec.feature "User activates a repo", :js do
  scenario "bulk user activates a repo" do
    user = create(:user, :with_github_scopes)
    repo = create(:repo, :private, name: "foo/bar")
    create(:bulk_customer, org: "foo")
    create(:membership, :admin, repo: repo, user: user)

    sign_in_as(user, "letmein")
    click_on "Activate"

    expect(page).to have_text "Active"
  end

  scenario "user upgrades from free plan" do
    user = create(:user, :with_github_scopes, :stripe)
    repo = create(:repo, :private)
    create(:membership, :admin, repo: repo, user: user)
    current_plan = user.current_plan.id
    upgraded_plan = user.next_plan.id
    stub_customer_find_request
    stub_subscription_create_request(plan: current_plan, repo_ids: repo.id)
    stub_subscription_update_request(plan: upgraded_plan, repo_ids: repo.id)

    sign_in_as(user, "letmein")
    click_on "Activate"

    expect(page).to have_text "Change of Plans"
  end

  scenario "user upgrades within a plan" do
    user = create(:user, :with_github_scopes, :stripe)
    repo = create(:repo, :private)
    create(:membership, :admin, repo: repo, user: user)
    create(:subscription, :active, user: user)
    current_plan = user.current_plan.id
    upgraded_plan = user.next_plan.id
    stub_customer_find_request
    stub_subscription_create_request(plan: current_plan, repo_ids: repo.id)
    stub_subscription_update_request(plan: upgraded_plan, repo_ids: repo.id)

    sign_in_as(user, "letmein")
    click_on "Activate"

    expect(page).to have_text "Private Repos 2 / 4"
  end

  after { Plan::PRICES[:private] = 0 }
end
