require "rails_helper"

describe RepoSubscriber do
  describe ".subscribe" do
    context "when Stripe customer exists" do
      context "when a subscription doesn't exist" do
        it "creates a new Stripe subscription" do
          repo = create(:repo, private: true)
          user = create(:user, :stripe, repos: [repo])
          stub_customer_find_request(user.stripe_customer_id)
          update_request = stub_customer_update_request
          subscription_request = stub_subscription_create_request(
            plan: StripePlan::PLANS[1][:id],
            repo_ids: repo.id,
          )
          subscription_update_request = stub_subscription_update_request(
            repo_ids: repo.id,
          )

          RepoSubscriber.subscribe(repo, user, nil)

          expect(subscription_request).to have_been_requested
          expect(subscription_update_request).to have_been_requested
          expect(update_request).not_to have_been_requested
          expect(repo.subscription.stripe_subscription_id).
            to eq(StripeApiHelper::STRIPE_SUBSCRIPTION_ID)
        end

        it "creates a Stripe subscription using new card" do
          repo = create(:repo, private: true)
          user = create(:user, :stripe, repos: [repo])
          stub_customer_find_request(user.stripe_customer_id)
          subscription_request = stub_subscription_create_request(
            plan: StripePlan::PLANS[1][:id],
            repo_ids: repo.id,
          )
          subscription_update_request = stub_subscription_update_request(
            repo_ids: repo.id,
          )
          customer_update_request = stub_customer_update_request(
            card: "card_token",
          )

          RepoSubscriber.subscribe(repo, user, "card_token")

          expect(subscription_request).to have_been_requested
          expect(subscription_update_request).to have_been_requested
          expect(customer_update_request).to have_been_requested
          expect(repo.subscription.stripe_subscription_id).
            to eq(StripeApiHelper::STRIPE_SUBSCRIPTION_ID)
        end
      end
    end

    context "when Stripe customer does not exist" do
      it "creates a new Stripe customer, subscription and repo subscription" do
        repo = create(:repo)
        user = create(:user, repos: [repo], stripe_customer_id: "",)
        customer_request = stub_customer_create_request(user)
        subscription_request = stub_subscription_create_request(
          plan: StripePlan::PLANS[1][:id],
          repo_ids: repo.id,
        )
        update_request = stub_subscription_update_request(repo_ids: repo.id)

        RepoSubscriber.subscribe(repo, user, "cardtoken")

        expect(customer_request).to have_been_requested
        expect(subscription_request).to have_been_requested
        expect(update_request).to have_been_requested
        expect(repo.subscription.stripe_subscription_id).
          to eq(StripeApiHelper::STRIPE_SUBSCRIPTION_ID)
        expect(user.stripe_customer_id).
          to eq StripeApiHelper::STRIPE_CUSTOMER_ID
      end
    end

    context "when Stripe subscription fails" do
      it "returns false" do
        repo = create(:repo)
        user = create(:user, repos: [repo])
        stub_customer_create_request(user)
        stub_failed_subscription_create_request(
          StripePlan::PLANS[1][:id],
        )

        result = RepoSubscriber.subscribe(repo, user, "cardtoken")

        expect(result).to be_falsy
      end

      it "reports raised exceptions to Sentry" do
        repo = build_stubbed(:repo)
        user = create(:user)
        stub_customer_create_request(user)
        stub_failed_subscription_create_request("plan_FXpsAlar939qfx")
        allow(Raven).to receive(:capture_exception)

        RepoSubscriber.subscribe(repo, user, "cardtoken")

        expect(Raven).to have_received(:capture_exception)
      end
    end

    context "when repo subscription fails to create" do
      it "doesn't raise and returns falsy" do
        repo = create(:repo)
        user = create(:user, repos: [repo])
        stub_customer_create_request(user)
        stub_subscription_create_request(
          plan: StripePlan::PLANS[1][:id],
          repo_ids: repo.id,
        )
        stub_subscription_update_request(repo_ids: repo.id)
        allow(repo).to receive(:create_subscription!).and_raise(StandardError)

        result = RepoSubscriber.subscribe(repo, user, "cardtoken")

        expect(result).to be_falsy
      end
    end

    context "when repo already has a subscription" do
      context "and it is not marked as deleted" do
        it "returns the existing subscription" do
          subscription = create(:subscription)

          result = RepoSubscriber.subscribe(
            subscription.repo,
            subscription.user,
            "cardtoken"
          )

          expect(result).to eq subscription
        end
      end
    end

    context "when another user has a subcription under the same account" do
      it "creates a new repo subscription under existing Stripe customer" do
        owner = create(:owner)
        repo1 = create(:repo, owner: owner)
        repo2 = create(:repo, owner: owner)
        main_stripe_user = create(:user, :stripe, repos: [repo1, repo2])
        current_user = create(:user, :stripe, repos: [repo1, repo2])
        create(:subscription, user: main_stripe_user, repo: repo1)
        stub_customer_find_request_with_subscriptions
        stub_subscription_create_request(
          plan: main_stripe_user.current_plan.id,
          repo_ids: repo2.id,
        )
        stub_subscription_update_request(repo_ids: repo2.id)

        subscription = RepoSubscriber.subscribe(repo2, current_user, nil)

        expect(subscription).to have_attributes(
          repo_id: repo2.id,
          user_id: main_stripe_user.id,
        )
      end
    end
  end

  describe ".unsubscribe" do
    it "downgrades the Stripe plan" do
      subscription = subscription_with_user
      stub_customer_find_request(subscription.user.stripe_customer_id)
      stub_subscription_find_request(subscription, quantity: 2)
      stripe_delete_request = stub_subscription_delete_request
      subscription_update_request = stub_subscription_update_request(
        repo_ids: "",
      )

      RepoSubscriber.unsubscribe(subscription.repo, subscription.user)

      expect(stripe_delete_request).not_to have_been_requested
      expect(subscription_update_request).to have_been_requested
    end

    context "when Stripe unsubscription fails" do
      it "returns false" do
        repo = build_stubbed(:repo)
        user = build_stubbed(:user, repos: [repo])
        stub_customer_create_request(user)
        stub_failed_subscription_destroy_request

        result = RepoSubscriber.unsubscribe(repo, user)

        expect(result).to be_falsy
      end

      it "reports raised exceptions to Sentry" do
        repo = build_stubbed(:repo)
        user = build_stubbed(:user, repos: [repo])
        stub_customer_create_request(user)
        stub_failed_subscription_destroy_request
        allow(Raven).to receive(:capture_exception)

        RepoSubscriber.unsubscribe(repo, user)

        expect(Raven).to have_received(:capture_exception)
      end
    end
  end

  def subscription_with_user
    user = create(:user, :stripe)
    repo = create(:repo, :private, users: [user])
    create(
      :subscription,
      stripe_subscription_id: StripeApiHelper::STRIPE_SUBSCRIPTION_ID,
      user: user,
      repo: repo,
    )
  end
end
