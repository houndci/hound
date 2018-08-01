require "rails_helper"

describe SubscriptionsController, "#create" do
  context "when repo has an installation id" do
    it "redirects to the GitHub upgrade url" do
      repo = create(:repo, installation_id: 123)
      membership = create(:membership, repo: repo)
      upgrade_url = "example.com/marketplace/plan"
      marketplace_plan = instance_double(
        "MarketplacePlan",
        upgrade?: true,
        upgrade_url: upgrade_url,
      )
      allow(MarketplacePlan).to receive(:new).and_return(marketplace_plan)
      stub_sign_in(membership.user)

      post :create, params: { repo_id: repo.id }, format: :json

      expect(response).to be_forbidden
      expect(JSON.parse(response.body)).to eq(
        "upgrade_url" => upgrade_url,
      )
    end
  end

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

  context "when the current plan is full" do
    it "notifies that payment is required" do
      membership = create(:membership)
      repo = membership.repo
      user = membership.user
      stub_sign_in(user)

      post :create, params: { repo_id: repo.id }

      expect(response).to have_http_status(:payment_required)
    end
  end

  describe "#update" do
    context "when the subscription cannot be created" do
      it "returns 'Bad Gateway'" do
        repo = instance_double(
          "Repo",
          id: 123,
          as_json: { active: true },
          name: "TEST_REPO_NAME",
          private?: true,
        )
        repo_activator = instance_double(
          "RepoActivator",
          activate: false,
          deactivate: true,
        )
        repos = class_double(Repo, find_by: repo)
        user = instance_double(
          "User",
          email: "TEST_USER_EMAIL",
          repos: repos,
          token: "TEST_USER_TOKEN",
          username: "jimtom",
        )
        allow(RepoActivator).to receive(:new).and_return(repo_activator)
        allow(User).to receive(:find_by).and_return(user)

        put :update, params: { repo_id: 1 }

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
            revenue: -subscribed_user.next_plan_price,
          }
        )
    end
  end
end
