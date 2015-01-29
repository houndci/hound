require "spec_helper"

describe RepoSubscriber do
  describe ".subscribe" do
    context "when Stripe customer exists" do
      it "creates a new Stripe subscription and repo subscription" do
        repo = create(:repo, private: true)
        user =
          create(:user, stripe_customer_id: stripe_customer_id, repos: [repo])
        stub_customer_find_request
        update_request = stub_customer_update_request
        subscription_request = stub_subscription_create_request(
          plan: repo.plan_type,
          repo_id: repo.id,
        )

        RepoSubscriber.subscribe(repo, user, "cardtoken")

        expect(subscription_request).to have_been_requested
        expect(update_request).not_to have_been_requested
        expect(repo.subscription.stripe_subscription_id).
          to eq(stripe_subscription_id)
        expect(repo.subscription_price).to(eq(Plan::PRICES[:private]))
      end
    end

    context "when Stripe customer does not exist" do
      it "creates a new Stripe customer, subscription and repo subscription" do
        repo = create(:repo)
        user = create(:user, repos: [repo], stripe_customer_id: "")
        customer_request = stub_customer_create_request(user)
        subscription_request =
          stub_subscription_create_request(plan: repo.plan_type)

        RepoSubscriber.subscribe(repo, user, "cardtoken")

        expect(customer_request).to have_been_requested
        expect(subscription_request).to have_been_requested
        expect(repo.subscription.stripe_subscription_id).
          to eq(stripe_subscription_id)
        expect(user.stripe_customer_id).to eq stripe_customer_id
      end
    end

    context "when Stripe subscription fails" do
      it "returns false" do
        repo = create(:repo)
        user = create(:user, repos: [repo])
        stub_customer_create_request(user)
        stub_failed_subscription_create_request(repo.plan_type)

        result = RepoSubscriber.subscribe(repo, user, "cardtoken")

        expect(result).to be_falsy
      end

      it "reports raised exceptions to Sentry" do
        repo = build_stubbed(:repo)
        user = create(:user, repos: [repo])
        stub_customer_create_request(user)
        stub_failed_subscription_create_request(repo.plan_type)
        allow(Raven).to receive(:capture_exception)

        RepoSubscriber.subscribe(repo, user, "cardtoken")

        expect(Raven).to have_received(:capture_exception)
      end
    end

    context "when repo subscription fails to create" do
      it "deleted the stripe subscription" do
        repo = create(:repo)
        user = create(:user, repos: [repo])
        stub_customer_create_request(user)
        stub_subscription_create_request(plan: repo.plan_type)
        stripe_delete_request = stub_subscription_delete_request
        allow(repo).to receive(:create_subscription!).and_raise(StandardError)

        result = RepoSubscriber.subscribe(repo, user, "cardtoken")

        expect(result).to be_falsy
        expect(stripe_delete_request).to have_been_requested
      end
    end
  end

  describe ".unsubscribe" do
    it "deletes Stripe subscription" do
      user = create(:user, stripe_customer_id: stripe_customer_id)
      subscription = create(
        :subscription,
        stripe_subscription_id: stripe_subscription_id,
        user: user
      )
      user.repos << subscription.repo
      stub_customer_find_request
      stub_subscription_find_request(subscription)
      stripe_delete_request = stub_subscription_delete_request

      RepoSubscriber.unsubscribe(subscription.repo, user)

      expect(stripe_delete_request).to have_been_requested
    end

    it "soft deletes the Repo subscription" do
      user = create(:user, stripe_customer_id: stripe_customer_id)
      subscription = create(
        :subscription,
        stripe_subscription_id: stripe_subscription_id,
        user: user
      )
      user.repos << subscription.repo
      stub_customer_find_request
      stub_subscription_find_request(subscription)
      stub_subscription_delete_request

      RepoSubscriber.unsubscribe(subscription.repo, user)

      expect(subscription.reload).to be_deleted
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
end
