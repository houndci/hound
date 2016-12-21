require "rails_helper"

describe SubscriptionsController, "#create" do
  context "when subscription succeeds" do
    it "subscribes the user to the repo" do
      repo = create(:repo, private: true)
      membership = create(:membership, repo: repo)
      create(:subscription, repo: repo, user: membership.user)
      activator = double(:repo_activator, activate: true)
      allow(RepoActivator).to receive(:new).and_return(activator)
      allow(RepoSubscriber).to receive(:subscribe).and_return(true)
      stub_sign_in(membership.user)

      post(
        :create,
        params: {
          repo_id: repo.id,
          card_token: "cardtoken",
          email: "jimtom@example.com",
        },
        format: :json
      )

      expect(activator).to have_received(:activate)
      expect(RepoActivator).to have_received(:new).
        with(repo: repo, github_token: membership.user.token)
      expect(RepoSubscriber).to have_received(:subscribe).
        with(repo, membership.user, "cardtoken")
    end

    it "updates the current user's email address" do
      user = create(:user, email: nil)
      repo = create(:repo)
      user.repos << repo
      activator = double(:repo_activator, activate: true)
      allow(RepoActivator).to receive(:new).and_return(activator)
      allow(RepoSubscriber).to receive(:subscribe).and_return(true)
      stub_sign_in(user)

      post(
        :create,
        params: {
          repo_id: repo.id,
          card_token: "cardtoken",
          email: "jimtom@example.com",
        },
        format: :json
      )

      expect(user.reload.email).to eq "jimtom@example.com"
    end
  end

  context "when subscription fails" do
    it "deactivates repo" do
      membership = create(:membership)
      repo = membership.repo
      create(:subscription, repo: repo, user: membership.user)
      activator = double(:repo_activator, activate: true, deactivate: nil)
      allow(RepoActivator).to receive(:new).and_return(activator)
      allow(RepoSubscriber).to receive(:subscribe).and_return(false)
      stub_sign_in(membership.user)

      post :create, params: { repo_id: repo.id }, format: :json

      expect(response.code).to eq "502"
      expect(activator).to have_received(:deactivate)
    end
  end

  context "when the current tier is full" do
    it "notifies that payment is required" do
      membership = create(:membership)
      repo = membership.repo
      tier = instance_double("Tier", full?: true)
      user = membership.user
      allow(Tier).to receive(:new).once.with(user).and_return(tier)
      stub_sign_in(user)

      post :create, params: { repo_id: repo.id }

      expect(response).to have_http_status(:payment_required)
    end
  end

  describe "#update" do
    it "creates a subscription" do
      hook_url = "http://#{ENV['HOST']}/builds"
      user = create(:user, :stripe)
      membership = create(:membership, user: user)
      tier = Tier.new(user)
      new_plan = tier.next.id
      plan = tier.current.id
      repo = membership.repo
      token = "letmein"
      stub_customer_find_request(user.stripe_customer_id)
      stub_sign_in(user)
      stub_hook_creation_request(repo.name, hook_url, token)
      stub_subscription_create_request(plan: plan, repo_ids: repo.id)
      stub_subscription_update_request(plan: new_plan, repo_ids: repo.id)

      put :update, params: { repo_id: repo.id }

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to include(
        "admin" => true,
        "active" => true,
        "full_plan_name" => "Public Repo",
        "id" => 1,
        "in_organization" => false,
        "owner" => nil,
        "price_in_cents" => 0,
        "price_in_dollars" => 0,
        "private" => false,
        "stripe_subscription_id" => "sub_488ZZngNkyRMiR",
      )
    end

    context "when the subscription cannot be created" do
      it "returns 'Bad Gateway'" do
        hook_id = 1
        hook_url = "http://#{ENV['HOST']}/builds"
        user = create(:user, :stripe)
        membership = create(:membership, user: user)
        plan = Tier.new(user).current.id
        repo = membership.repo
        token = "letmein"
        stub_customer_find_request(user.stripe_customer_id)
        stub_failed_subscription_create_request(plan)
        stub_sign_in(user)
        stub_hook_creation_request(repo.name, hook_url, token)
        stub_hook_removal_request(repo.name, hook_id)

        put :update, params: { repo_id: repo.id }

        expect(response).to have_http_status(:bad_gateway)
      end
    end
  end
end

describe SubscriptionsController, "#destroy" do
  context "when there is no subscription" do
    it "returns 409 conflict" do
      current_user = create(:user)
      repo = create(:repo, private: true)
      create(:membership, repo: repo, user: current_user)
      activator = double("RepoActivator", deactivate: true)
      allow(RepoActivator).to receive(:new).and_return(activator)
      stub_sign_in(current_user)

      delete(
        :destroy,
        params: {
          repo_id: repo.id,
          card_token: "cardtoken",
        },
        format: :json
      )

      expect(response.status).to eq(409)
      response_body = JSON.parse(response.body)
      expect(response_body["errors"]).
        to eq(["No subscription exists for this repo"])
    end
  end

  context "when there is a subscription" do
    it "deletes subscription associated with subscribing user" do
      current_user = create(:user)
      subscribed_user = create(:user)
      repo = create(:repo, private: true)
      create(:membership, repo: repo, user: current_user)
      create(:subscription, repo: repo, user: subscribed_user)
      activator = double("RepoActivator", deactivate: true)
      allow(RepoActivator).to receive(:new).and_return(activator)
      allow(RepoSubscriber).to receive(:unsubscribe).and_return(true)
      stub_sign_in(current_user)

      delete(
        :destroy,
        params: {
          repo_id: repo.id,
          card_token: "cardtoken",
        },
        format: :json
      )

      expect(activator).to have_received(:deactivate)
      expect(RepoActivator).to have_received(:new).
        with(repo: repo, github_token: current_user.token)
      expect(RepoSubscriber).to have_received(:unsubscribe).
        with(repo, subscribed_user)
      expect(analytics).to have_tracked("Repo Deactivated").
        for_user(current_user).
        with(
          properties: {
            name: repo.name,
            private: true,
            revenue: -repo.plan_price,
          }
        )
    end
  end
end
