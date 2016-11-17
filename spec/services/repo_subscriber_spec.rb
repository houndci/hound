require "rails_helper"

describe RepoSubscriber do
  describe ".subscribe" do
    context "when Stripe customer exists" do
      context "when a subscription doesn't exist" do
        it "creates a new Stripe subscription and repo subscription" do
          repo = create(:repo, private: true)
          user = create(
            :user,
            stripe_customer_id: stripe_customer_id,
            repos: [repo],
          )
          stub_customer_find_request
          update_request = stub_customer_update_request
          subscription_request = stub_subscription_create_request(
            plan: user.current_tier.id,
            repo_ids: repo.id,
          )
          subscription_update_request = stub_subscription_update_request(
            plan: user.next_tier.id,
            repo_ids: repo.id,
          )

          RepoSubscriber.subscribe(repo, user, "cardtoken")

          expect(subscription_request).to have_been_requested
          expect(subscription_update_request).to have_been_requested
          expect(update_request).not_to have_been_requested
          expect(repo.subscription.stripe_subscription_id).
            to eq(stripe_subscription_id)
          expect(repo.subscription_price).to(eq(Plan::PRICES[:private]))
        end
      end

      context "when a subscription exists" do
        it "increments the Stripe subscription and updates repo subscription" do
          repo = create(:repo, private: true)
          user = create(
            :user,
            stripe_customer_id: stripe_customer_id,
            repos: [repo],
          )
          stub_customer_find_request_with_subscriptions
          subscription_update_request = stub_subscription_update_request(
            plan: "tier1",
            repo_ids: repo.id,
          )
          subscription_create_request = stub_subscription_create_request(
            plan: "basic",
            repo_ids: repo.id,
          )

          RepoSubscriber.subscribe(repo, user, "cardtoken")

          expect(subscription_create_request).to have_been_requested
          expect(subscription_update_request).to have_been_requested
          expect(repo.subscription.stripe_subscription_id).
            to eq(stripe_subscription_id)
          expect(repo.subscription_price).to(eq(Plan::PRICES[:private]))
        end
      end
    end

    context "when Stripe customer does not exist" do
      it "creates a new Stripe customer, subscription and repo subscription" do
        repo = create(:repo)
        user = create(:user, repos: [repo], stripe_customer_id: "",)
        customer_request = stub_customer_create_request(user)
        subscription_request = stub_subscription_create_request(
          plan: user.current_tier.id,
          repo_ids: repo.id,
        )
        update_request = stub_subscription_update_request(
          plan: user.next_tier.id,
          repo_ids: repo.id,
        )

        RepoSubscriber.subscribe(repo, user, "cardtoken")

        expect(customer_request).to have_been_requested
        expect(subscription_request).to have_been_requested
        expect(update_request).to have_been_requested
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
        stub_failed_subscription_create_request(user.current_tier.id)

        result = RepoSubscriber.subscribe(repo, user, "cardtoken")

        expect(result).to be_falsy
      end

      it "reports raised exceptions to Sentry" do
        repo = build_stubbed(:repo)
        user = create(:user)
        stub_customer_create_request(user)
        stub_failed_subscription_create_request(user.current_tier.id)
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
        stub_subscription_create_request(
          plan: user.current_tier.id,
          repo_ids: repo.id,
        )
        stub_subscription_update_request(
          plan: user.next_tier.id,
          repo_ids: repo.id,
        )
        stripe_delete_request = stub_subscription_delete_request
        allow(repo).to receive(:create_subscription!).and_raise(StandardError)

        result = RepoSubscriber.subscribe(repo, user, "cardtoken")

        expect(result).to be_falsy
        expect(stripe_delete_request).to have_been_requested
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
  end

  describe ".unsubscribe" do
    it "updates the Stripe plan" do
      subscription = subscription_with_user
      stub_customer_find_request
      stub_subscription_find_request(subscription, quantity: 2)
      stripe_delete_request = stub_subscription_delete_request
      subscription_update_request = stub_subscription_update_request(
        plan: "basic",
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
    user = create(:user, stripe_customer_id: stripe_customer_id)
    subscription = create(
      :subscription,
      stripe_subscription_id: stripe_subscription_id,
      user: user,
    )
    user.repos << subscription.repo
    subscription
  end
end
