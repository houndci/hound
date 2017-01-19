require "rails_helper"

feature "user deactivates a repo", js: true do
  context "when the user has a subscription" do
    context "when the user does not have a membership" do
      scenario "successfully deactivates the repo" do
        token = "letmein"
        user = create(:user, token_scopes: "public_repo,user:email")
        repo = create(:repo, :active, private: true)
        create(:subscription, user: user, repo: repo)
        gateway_subscription = instance_double(
          "PaymentGatewaySubscription",
          unsubscribe: true,
        )
        payment_gateway_customer = instance_double(
          "PaymentGatewayCustomer",
          retrieve_subscription: gateway_subscription,
          email: user.email,
        )
        allow(PaymentGatewayCustomer).to receive(:new).and_return(
          payment_gateway_customer
        )

        sign_in_as(user, token)
        find(".repo-toggle").click

        expect(page).not_to have_css(".active")

        visit current_path

        expect(page).not_to have_selector(".repo")
      end
    end
  end

  scenario "user downgrades within a tier" do
    user = create(:user, :with_github_scopes, :stripe)
    first_subscription = create(:subscription, :active, user: user)
    second_subscription = create(:subscription, :active, user: user)
    tier = Tier.new(user)
    previous_tier = tier.previous
    downgraded_plan = previous_tier.id
    stub_customer_find_request
    stub_subscription_find_request(first_subscription)
    stub_subscription_find_request(second_subscription)
    stub_subscription_update_request(plan: downgraded_plan, repo_ids: "")

    sign_in_as(user, "letmein")
    find(".repo--active:nth-of-type(1) .repo-toggle").click

    expect(page).to have_text "Private Repos 1 / 4"
  end

  scenario "user downgrades from another tier" do
    user = create(:user, :with_github_scopes, :stripe)
    4.times do
      subscription = create(:subscription, :active, user: user)
      stub_subscription_find_request(subscription)
    end
    subscription = create(:subscription, :active, user: user)
    stub_subscription_find_request(subscription)
    tier = Tier.new(user)
    previous_tier = tier.previous
    downgraded_plan = previous_tier.id
    stub_customer_find_request
    stub_subscription_update_request(plan: downgraded_plan, repo_ids: "")

    sign_in_as(user, "letmein")
    find(".repo--active:nth-of-type(1) .repo-toggle").click

    expect(page).to have_text "Private Repos 4 / 4"
  end

  scenario "user downgrades to free tier" do
    user = create(:user, :with_github_scopes, :stripe)
    subscription = create(:subscription, :active, user: user)
    stub_subscription_find_request(subscription)
    tier = Tier.new(user)
    previous_tier = tier.previous
    downgraded_plan = previous_tier.id
    stub_customer_find_request
    stub_subscription_update_request(plan: downgraded_plan, repo_ids: "")

    sign_in_as(user, "letmein")
    find(".repo--active:nth-of-type(1) .repo-toggle").click

    expect(page).to_not have_css(".allowance")
  end
end
