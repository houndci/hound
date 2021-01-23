require "rails_helper"

feature "user deactivates a repo", js: true do
  context "when the user has a subscription" do
    context "when the user does not have a membership" do
      scenario "successfully deactivates the repo" do
        token = "letmein"
        user = create(:user)
        repo = create(:repo, :active, private: true)
        create(:subscription, user: user, repo: repo)
        gateway_subscription = instance_double(
          "PaymentGatewaySubscription",
          unsubscribe: true,
          plan: "plan_FXpsAlar939qfx"
        )
        payment_gateway_customer = instance_double(
          "PaymentGatewayCustomer",
          retrieve_subscription: gateway_subscription,
          email: user.email,
          subscription: gateway_subscription
        )
        allow(PaymentGatewayCustomer).
          to receive(:new).
          and_return(payment_gateway_customer)

        sign_in_as(user, token)
        find(".repo-toggle").click

        expect(page).not_to have_css(".active")

        visit current_path

        expect(page).not_to have_css(".repos-syncing")
        expect(page).not_to have_text(repo.name)
      end
    end
  end
end
