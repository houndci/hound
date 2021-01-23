require "rails_helper"

describe SubscriptionsController do
  describe "#create" do
    context "when subscription succeeds" do
      context "with Metered subscription" do
        it "subscribes the user to the repo" do
          repo = create(:repo, private: true)
          user = create(:user, :stripe)
          membership = create(:membership, repo: repo, user: user)
          create(:subscription, repo: repo, user: user)
          allow(RepoSubscriber).to receive(:subscribe).and_return(true)
          stub_sign_in(user)
          stub_customer_find_request_with_subscriptions

          post(
            :create,
            params: {
              repo_id: repo.id,
              card_token: "cardtoken",
              email: "jimtom@example.com",
            },
            format: :json,
          )

          expect(RepoSubscriber).to have_received(:subscribe).
            with(repo, membership.user, "cardtoken")
        end
      end

      context "with GitHub subscription" do
        it "subscribes the user to the repo" do
          repo = create(:repo, private: true)
          repo.owner.update!(marketplace_plan_id: GitHubPlan::PLANS.last[:id])
          membership = create(:membership, repo: repo)
          allow(RepoSubscriber).to receive(:subscribe)
          stub_sign_in(membership.user)

          post(
            :create,
            params: {
              repo_id: repo.id,
              card_token: "cardtoken",
              email: "jimtom@example.com",
            },
            format: :json,
          )

          expect(RepoSubscriber).not_to have_received(:subscribe)
        end
      end

      it "updates the current user's email address" do
        user = create(:user, email: nil)
        repo = create(:repo)
        user.repos << repo
        allow(RepoSubscriber).to receive(:subscribe).and_return(true)
        stub_sign_in(user)

        post(
          :create,
          params: {
            repo_id: repo.id,
            card_token: "cardtoken",
            email: "jimtom@example.com",
          },
          format: :json,
        )

        expect(user.reload.email).to eq "jimtom@example.com"
      end
    end

    context "when subscription fails" do
      it "deactivates repo" do
        repo = create(:repo, private: true)
        user = create(:user, :stripe)
        membership = create(:membership, repo: repo, user: user)
        create(:subscription, repo: repo, user: user)
        deactivate_repo = instance_double("DeactivateRepo", call: nil)
        allow(DeactivateRepo).to receive(:new).and_return(deactivate_repo)
        allow(RepoSubscriber).to receive(:subscribe).and_return(false)
        stub_sign_in(user)
        stub_customer_find_request_with_subscriptions

        post :create, params: { repo_id: repo.id }, format: :json

        expect(response.code).to eq "502"
        expect(deactivate_repo).to have_received(:call)
      end
    end

    context "when the current plan is open source (free)" do
      it "notifies that payment is required" do
        membership = create(:membership)
        repo = membership.repo
        user = membership.user
        stub_sign_in(user)

        post :create, params: { repo_id: repo.id }

        expect(response).to have_http_status(:payment_required)
      end
    end
  end

  describe "#update" do
    context "when the subscription can be created" do
      it "returns 'Created'" do
        repo = create(:repo, name: "foo/bar", private: true)
        user = create(:user, repos: [repo])
        create(:subscription, repo: repo, user: user)
        stub_sign_in(user)

        put :update, params: { repo_id: repo.id }

        expect(response).to have_http_status(:created)
      end
    end

    context "when the subscription cannot be created" do
      it "returns an error and deactivates the repo" do
        repo = create(:repo, name: "foo/bar", private: true)
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

        delete(
          :destroy,
          params: {
            repo_id: repo.id,
            card_token: "cardtoken",
          },
          format: :json,
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
        deactivate_repo = instance_double("DeactivateRepo", call: true)
        allow(DeactivateRepo).to receive(:new).and_return(deactivate_repo)
        allow(RepoSubscriber).to receive(:unsubscribe).and_return(true)
        stub_sign_in(current_user)

        delete(
          :destroy,
          params: {
            repo_id: repo.id,
            card_token: "cardtoken",
          },
          format: :json,
        )

        expect(deactivate_repo).to have_received(:call)
        expect(DeactivateRepo).to have_received(:new).
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
            },
          )
      end
    end
  end
end
