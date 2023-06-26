require "rails_helper"

describe SubscriptionsController do
  describe "#create" do
    context "when subscription succeeds" do
      context "with existing Stripe subscriber" do
        it "responds with activated repo" do
          owner = create(:owner, :stripe)
          repo = create(:repo, owner: owner, private: true)
          user = create(:user, repos: [repo])
          stub_customer_find_request_with_subscriptions
          stub_sign_in(user)

          post :create, params: { repo_id: repo.id, card_token: "cardtoken" }

          expect(response.status).to eq 201
          expect(JSON.parse(response.body)).to match hash_including(
            "name" => repo.name,
            "active" => true,
            "owner" => hash_including("name" => owner.name),
          )
        end
      end

      context "with GitHub Marketplace subscriber" do
        it "subscribes the user to the repo" do
          owner = create(:owner, marketplace_plan_id: GitHubPlan::PLANS[1][:id])
          repo = create(:repo, owner: owner, private: true)
          user = create(:user, repos: [repo])
          stub_sign_in(user)

          post :create, params: { repo_id: repo.id, card_token: "cardtoken" }

          expect(response.status).to eq 201
          expect(JSON.parse(response.body)).to match hash_including(
            "name" => repo.name,
            "active" => true,
            "owner" => hash_including("name" => owner.name),
          )
        end
      end

      it "updates the current user's email address" do
        repo = create(:repo)
        user = create(:user, email: nil, repos: [repo])
        stub_sign_in(user)

        post :create, params: { repo_id: repo.id, email: "jimtom@example.com" }

        expect(user.reload.email).to eq "jimtom@example.com"
      end
    end

    context "when repo activation requires payment" do
      it "responds with payment_required and does not activate the repo" do
        repo = create(:repo, private: true)
        user = create(:user, repos: [repo])
        stub_sign_in(user)

        post :create, params: { repo_id: repo.id }

        expect(response).to have_http_status(:payment_required)
        expect(repo.reload.active).to eq false
      end
    end

    context "when the current plan requires an upgrade" do
      it "notifies that payment is required" do
        owner = create(:owner, marketplace_plan_id: GitHubPlan::PLANS[0][:id])
        repo = create(:repo, owner: owner, private: true)
        user = create(:user, repos: [repo])
        stub_sign_in(user)

        post :create, params: { repo_id: repo.id }

        expect(response).to have_http_status(:payment_required)
        expect(repo.reload.active).to eq false
      end
    end
  end

  # need to figure out what this action is for and how to simplify it
  describe "#update" do
    context "when the subscription can be created" do
      it "returns 'Created'" do
        repo = create(:repo, private: true)
        user = create(:user, repos: [repo])
        create(:subscription, repo: repo, user: user)
        stub_sign_in(user)

        put :update, params: { repo_id: repo.id }

        expect(response).to have_http_status(:created)
      end
    end

    context "when the subscription cannot be created" do
      it "returns an error and deactivates the repo" do
        repo = create(:repo, private: true)
        user = create(:user, repos: [repo])
        deactivate_repo = instance_double("DeactivateRepo", call: nil)
        allow(RepoSubscriber).to receive(:subscribe).and_return(false)
        allow(DeactivateRepo).to receive(:new).and_return(deactivate_repo)
        stub_sign_in(user)

        put :update, params: { repo_id: repo.id }

        expect(deactivate_repo).to have_received(:call)
        expect(response).to have_http_status(:bad_gateway)
        expect(JSON.parse(response.body)).to eq(
          "errors" => ["There was an issue creating the subscription"],
        )
      end
    end
  end

  describe "#destroy" do
    context "when there is no subscription" do
      it "returns 409 conflict" do
        current_user = create(:user)
        repo = create(:repo, private: true)
        create(:membership, repo: repo, user: current_user)
        deactivate_repo = instance_double("DeactivateRepo", call: true)
        allow(DeactivateRepo).to receive(:new).and_return(deactivate_repo)
        stub_sign_in(current_user)

        delete :destroy, params: { repo_id: repo.id, card_token: "cardtoken" }

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
        deactivate_repo = instance_double("DeactivateRepo", call: true)
        allow(DeactivateRepo).to receive(:new).and_return(deactivate_repo)
        allow(RepoSubscriber).to receive(:unsubscribe).and_return(true)
        stub_sign_in(current_user)

        delete :destroy, params: { repo_id: repo.id, card_token: "cardtoken" }

        expect(deactivate_repo).to have_received(:call)
        expect(DeactivateRepo).to have_received(:new).
          with(repo: repo, github_token: current_user.token)
        expect(RepoSubscriber).to have_received(:unsubscribe).
          with(repo, subscribed_user)
        expect(analytics).to have_tracked("Repo Deactivated").
          for_user(current_user).
          with(properties: { name: repo.name, private: true })
      end
    end
  end
end
