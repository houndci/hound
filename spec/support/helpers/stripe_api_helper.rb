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
      stripe_base_url
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

  def stub_customer_find_request(customer_id = stripe_customer_id)
    stub_request(
      :get,
      "#{stripe_base_url}/#{customer_id}"
    ).with(
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/stripe_customer_find.json"),
    )
  end

  def stub_customer_find_request_with_subscriptions
    stub_request(:get, "#{stripe_base_url}/#{stripe_customer_id}").with(
      headers: { "Authorization" => "Bearer #{ENV['STRIPE_API_KEY']}" }
    ).to_return(
      status: 200,
      body: File.read(
        "spec/support/fixtures/stripe_customer_find_with_subscriptions.json"
      )
    )
  end

  def stub_customer_update_request(attrs = { card: "card-token" })
    stub_request(
      :post,
      "#{stripe_base_url}/#{stripe_customer_id}"
    ).with(
      body: attrs,
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/stripe_customer_update.json"),
    )
  end

  def stub_failed_customer_update_request(attrs = { email: "email@foo.com" })
    stub_request(
      :post,
      "#{stripe_base_url}/#{stripe_customer_id}"
    ).with(
      body: attrs,
      headers: { "Authorization" => "Bearer #{ENV['STRIPE_API_KEY']}" }
    ).to_return(
      status: 500,
      body: {
        error: {
          message: "Something went wrong",
          type: "api_error"
        }
      }.to_json
    )
  end

  def stub_subscription_create_request(plan: "free", repo_ids: "")
    body = {
      "plan" => plan,
      "metadata" => { "repo_ids" => repo_ids.to_s }
    }
    stub_request(
      :post,
      "#{stripe_base_url}/#{stripe_customer_id}/subscriptions"
    ).with(
      body: hash_including(body),
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/stripe_subscription_create.json"),
    )
  end

  def stub_subscription_update_request(plan:, repo_ids:)
    body = { metadata: { repo_ids: repo_ids.to_s }, plan: plan }

    stub_request(
      :post,
      "#{stripe_base_url}/#{stripe_customer_id}/"\
        "subscriptions/#{stripe_subscription_id}"
    ).with(
      body: body,
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/stripe_subscription_update.json"),
    )
  end

  def stub_subscription_find_request(subscription, quantity: 1)
    body = JSON.parse(
      File.read("spec/support/fixtures/stripe_subscription_find.json")
    )
    body["quantity"] = quantity
    request_url = "#{stripe_base_url}/#{stripe_customer_id}/"\
      "subscriptions/#{subscription.stripe_subscription_id}"

    stub_request(:get, request_url).with(
      headers: { "Authorization" => "Bearer #{ENV['STRIPE_API_KEY']}" }
    ).to_return(status: 200, body: body.to_json)
  end

  def stub_subscription_delete_request
    stub_request(
      :delete,
      "#{stripe_base_url}/#{stripe_customer_id}/"\
      "subscriptions/#{stripe_subscription_id}"
    ).with(
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/stripe_subscription_delete.json"),
    )
  end

  def stub_subscription_meta_data_update_request(subscription)
    stub_request(
      :post,
      "#{stripe_base_url}/#{stripe_customer_id}/"\
        "subscriptions/#{stripe_subscription_id}"
    ).with(
      body: { metadata: { repo_ids: subscription.repo_id.to_s } },
      headers: { "Authorization" => "Bearer #{ENV["STRIPE_API_KEY"]}" }
    ).to_return(
      status: 200,
      body: File.read("spec/support/fixtures/stripe_subscription_update.json"),
    )
  end

  def stub_failed_subscription_create_request(plan_type)
    stub_request(
      :post,
      "#{stripe_base_url}/#{stripe_customer_id}/subscriptions"
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
      "#{stripe_base_url}/#{stripe_customer_id}/subscriptions"
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

  def stripe_base_url
    "https://api.stripe.com/v1/customers"
  end
end
