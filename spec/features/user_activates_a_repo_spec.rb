require "rails_helper"

RSpec.feature "User activates a repo", :js do
  scenario "user upgrades from free tier" do
    callback_endpoint = "http://#{ENV['HOST']}/builds"
    user = create(:user, :with_github_scopes, :stripe)
    membership = create(:membership, :admin, :private, user: user)
    current_plan = user.current_tier.id
    upgraded_plan = user.next_tier.id
    repo = membership.repo
    token = "letmein"
    stub_add_collaborator_request(Hound::GITHUB_USERNAME, repo.name, token)
    stub_customer_find_request
    stub_hook_creation_request(repo.name, callback_endpoint, token)
    stub_subscription_create_request(plan: current_plan, repo_ids: repo.id)
    stub_subscription_update_request(plan: upgraded_plan, repo_ids: repo.id)

    sign_in_as(user, "letmein")
    click_on "Activate"

    expect(page).to have_text "Private Repos 1 / 4"
  end

  scenario "user upgrades within a tier" do
    callback_endpoint = "http://#{ENV['HOST']}/builds"
    user = create(:user, :with_github_scopes, :stripe)
    membership = create(:membership, :admin, :private, user: user)
    create(:subscription, :active, user: user)
    current_plan = user.current_tier.id
    upgraded_plan = user.next_tier.id
    repo = membership.repo
    token = "letmein"
    stub_add_collaborator_request(Hound::GITHUB_USERNAME, repo.name, token)
    stub_customer_find_request
    stub_hook_creation_request(repo.name, callback_endpoint, token)
    stub_subscription_create_request(plan: current_plan, repo_ids: repo.id)
    stub_subscription_update_request(plan: upgraded_plan, repo_ids: repo.id)

    sign_in_as(user, "letmein")
    click_on "Activate"

    expect(page).to have_text "Private Repos 2 / 4"
  end
end
