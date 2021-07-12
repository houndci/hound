require "rails_helper"

RSpec.feature "User activates a repo", :js do
  scenario "user upgrades from free plan" do
    user = create(:user, :stripe)
    repo = create(:repo, :private)
    create(:membership, :admin, repo: repo, user: user)
    stub_customer_find_request(user.stripe_customer_id)
    current_plan = user.current_plan.id
    stub_subscription_create_request(plan: current_plan, repo_ids: repo.id)

    sign_in_as(user, "letmein")
    click_on "Activate"

    expect(page).to have_text "Change of Plans"
  end
end
