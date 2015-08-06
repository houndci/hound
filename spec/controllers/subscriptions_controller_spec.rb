require "rails_helper"

describe SubscriptionsController, "#create" do
  context "when subscription succeeds" do
    it "subscribes the user to the repo" do
      repo = create(:repo, private: true)
      membership = create(:membership, repo: repo)
      activator = double(:repo_activator, activate: true)
      allow(RepoActivator).to receive(:new).and_return(activator)
      allow(RepoSubscriber).to receive(:subscribe).and_return(true)
      stub_sign_in(membership.user)

      post(
        :create,
        repo_id: repo.id,
        card_token: "cardtoken",
        email_address: "jimtom@example.com",
        format: :json
      )

      expect(activator).to have_received(:activate)
      expect(RepoActivator).to have_received(:new).
        with(repo: repo, github_token: membership.user.token)
      expect(RepoSubscriber).to have_received(:subscribe).
        with(repo, membership.user, "cardtoken")
      expect(analytics).to have_tracked("Repo Activated").
        for_user(membership.user).
        with(
          properties: {
            name: repo.name,
            private: true,
            revenue: repo.plan_price,
          }
        )
    end

    it "updates the current user's email address" do
      user = create(:user, email_address: nil)
      repo = create(:repo)
      user.repos << repo
      activator = double(:repo_activator, activate: true)
      allow(RepoActivator).to receive(:new).and_return(activator)
      allow(RepoSubscriber).to receive(:subscribe).and_return(true)
      stub_sign_in(user)

      post(
        :create,
        repo_id: repo.id,
        card_token: "cardtoken",
        email_address: "jimtom@example.com",
        format: :json
      )

      expect(user.reload.email_address).to eq "jimtom@example.com"
    end
  end

  context "when subscription fails" do
    it "deactivates repo" do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, activate: true, deactivate: nil)
      allow(RepoActivator).to receive(:new).and_return(activator)
      allow(RepoSubscriber).to receive(:subscribe).and_return(false)
      stub_sign_in(membership.user)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq "502"
      expect(activator).to have_received(:deactivate)
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
        repo_id: repo.id,
        card_token: "cardtoken",
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
        repo_id: repo.id,
        card_token: "cardtoken",
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
