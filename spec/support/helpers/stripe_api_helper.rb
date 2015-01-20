module StripeApiHelper
  def stripe_customer_id
    "cus_2e3fqARc1uHtCv"
  end

  def stripe_subscription_id
    "sub_488ZZngNkyRMiR"
  end

  def stub_customer_create_request(user)
    stub_request(
      :post,
      "https://api.stripe.com/v1/customers"
    ).with(
      body: {
        "card" => "cardtoken",
        "metadata" => { "user_id" => "#{user.id}" }
      },
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/stripe_customer_create.json"),
    )
  end

  def stub_customer_find_request
    stub_request(
      :get,
      "https://api.stripe.com/v1/customers/#{stripe_customer_id}"
    ).with(
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/stripe_customer_find.json"),
    )
  end

  def stub_customer_update_request(card_token = "cardtoken")
    stub_request(
      :post,
      "https://api.stripe.com/v1/customers/#{stripe_customer_id}"
    ).with(
      body: { "card" => card_token },
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
      "https://api.stripe.com/v1/customers/#{stripe_customer_id}/subscriptions"
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
      "https://api.stripe.com/v1/customers/#{stripe_customer_id}/subscriptions/#{subscription.stripe_subscription_id}"
    ).with(
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/stripe_subscription_find.json"),
    )
  end

  def stub_subscription_delete_request
    stub_request(
      :delete,
      "https://api.stripe.com/v1/customers/#{stripe_customer_id}/subscriptions/#{stripe_subscription_id}"
    ).with(
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/stripe_subscription_delete.json"),
    )
  end

  def stub_failed_subscription_create_request(plan_type)
    stub_request(
      :post,
      "https://api.stripe.com/v1/customers/#{stripe_customer_id}/subscriptions"
    ).with(
      body: hash_including("plan" => plan_type),
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}" }
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
      "https://api.stripe.com/v1/customers/#{stripe_customer_id}/subscriptions"
    ).with(
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}" }
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
