require "spec_helper"

describe RepoSubscriber do
  STRIPE_CUSTOMER_ID = "cus_2e3fqARc1uHtCv"
  STRIPE_SUBSCRIPTION_ID = "sub_488ZZngNkyRMiR"

  describe ".subscribe" do
    context "when Stripe customer exists" do
      it "creates a new Stripe subscription and repo subscription" do
        repo = create(:repo, private: true)
        user =
          create(:user, stripe_customer_id: STRIPE_CUSTOMER_ID, repos: [repo])
        stub_customer_find_request
        update_request = stub_customer_update_request
        subscription_request = stub_subscription_create_request(
          plan: repo.plan_type,
          repo_id: repo.id,
        )

        RepoSubscriber.subscribe(repo, user, "cardtoken")

        expect(subscription_request).to have_been_requested
        expect(update_request).to have_been_requested
        expect(repo.subscription.stripe_subscription_id).
          to eq(STRIPE_SUBSCRIPTION_ID)
        expect(repo.subscription_price).to(eq(Plan::PRICES[:private]))
      end
    end

    context "when Stripe customer does not exist" do
      it "creates a new Stripe customer, subscription and repo subscription" do
        repo = create(:repo)
        user = create(:user, repos: [repo])
        customer_request = stub_customer_create_request(user)
        subscription_request =
          stub_subscription_create_request(plan: repo.plan_type)

        RepoSubscriber.subscribe(repo, user, "cardtoken")

        expect(customer_request).to have_been_requested
        expect(subscription_request).to have_been_requested
        expect(repo.subscription.stripe_subscription_id).
          to eq(STRIPE_SUBSCRIPTION_ID)
        expect(user.stripe_customer_id).to eq STRIPE_CUSTOMER_ID
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
      user = create(:user, stripe_customer_id: STRIPE_CUSTOMER_ID)
      subscription = create(
        :subscription,
        stripe_subscription_id: STRIPE_SUBSCRIPTION_ID,
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
      user = create(:user, stripe_customer_id: STRIPE_CUSTOMER_ID)
      subscription = create(
        :subscription,
        stripe_subscription_id: STRIPE_SUBSCRIPTION_ID,
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

  def stub_customer_create_request(user)
    stub_request(
      :post,
      "https://api.stripe.com/v1/customers"
    ).with(
      body: { "card" => "cardtoken", "metadata" => { "user_id"=>"#{user.id}" } },
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/stripe_customer_create.json"),
    )
  end

  def stub_customer_find_request
    stub_request(
      :get,
      "https://api.stripe.com/v1/customers/#{STRIPE_CUSTOMER_ID}"
    ).with(
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/stripe_customer_find.json"),
    )
  end

  def stub_customer_update_request
    stub_request(
      :post,
      "https://api.stripe.com/v1/customers/#{STRIPE_CUSTOMER_ID}"
    ).with(
      body: { "card" => "cardtoken" },
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/stripe_customer_update.json"),
    )
  end

  def stub_subscription_create_request(plan: "free", repo_id: nil)
    body = { "plan" => plan }
    if repo_id
      body.merge!("metadata" => { "repo_id" => repo_id.to_s })
    end
    stub_request(
      :post,
      "https://api.stripe.com/v1/customers/#{STRIPE_CUSTOMER_ID}/subscriptions"
    ).with(
      body: hash_including(body),
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/stripe_subscription_create.json"),
    )
  end

  def stub_subscription_find_request(subscription)
    stub_request(
      :get,
      "https://api.stripe.com/v1/customers/#{STRIPE_CUSTOMER_ID}/subscriptions/#{subscription.stripe_subscription_id}"
    ).with(
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}",}
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/stripe_subscription_find.json"),
    )
  end

  def stub_subscription_delete_request
    stub_request(
      :delete,
      "https://api.stripe.com/v1/customers/#{STRIPE_CUSTOMER_ID}/subscriptions/#{STRIPE_SUBSCRIPTION_ID}"
    ).with(
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}",}
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/stripe_subscription_delete.json"),
    )
  end

  def stub_failed_subscription_create_request(plan_type)
    stub_request(
      :post,
      "https://api.stripe.com/v1/customers/#{STRIPE_CUSTOMER_ID}/subscriptions"
    ).with(
      body: hash_including("plan" => plan_type),
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}",}
    ).to_return(
      status: 402,
      body: {
        error: {
          message: "Your credit card was declined",
          type: "card_error",
          param: "number",
          code: "incorrect_number"
        }
      }.to_json
    )
  end

  def stub_failed_subscription_destroy_request
    stub_request(
      :destroy,
      "https://api.stripe.com/v1/customers/#{STRIPE_CUSTOMER_ID}/subscriptions"
    ).with(
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}"}
    ).to_return(
      status: 402,
      body: {
        error: {
          message: "Error",
          type: "error",
        }
      }.to_json
    )
  end
end
