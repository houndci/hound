require "rails_helper"

feature "Account" do
  scenario "user without Stripe Customer ID" do
    user = create(:user, stripe_customer_id: nil)

    sign_in_as(user)
    visit account_path

    expect(page).not_to have_text("Update Credit Card")
  end

  scenario "user with Stripe Customer ID", js: true do
    user = create(:user, stripe_customer_id: "123")
    stub_customer_find_request(user.stripe_customer_id)

    sign_in_as(user)
    visit account_path

    expect(page).to have_text("Update Credit Card")
  end

  scenario "returns a list of all plans", :js do
    user = create(:user)
    sign_in_as(user, "letmein")

    visit account_path

    plans = page.all(".plan")
    expect(plans.count).to eq 7

    within(plans[0]) do
      expect(page).to have_text("CURRENT PLAN")

      expect(find(".plan-title")).to have_text "Open Source"
      expect(find(".plan-allowance")).to have_text "Unlimited"
      expect(find(".plan-price")).to have_text "$0 month"
    end

    within(plans[1]) do
      expect(find(".plan-title")).to have_text "Chihuahua"
      expect(find(".plan-allowance")).to have_text "Up to 50 Reviews"
      expect(find(".plan-price")).to have_text "$29 month"
    end

    within(plans[2]) do
      expect(find(".plan-title")).to have_text "Terrier"
      expect(find(".plan-allowance")).to have_text "Up to 300 Reviews"
      expect(find(".plan-price")).to have_text "$49 month"
    end

    within(plans[3]) do
      expect(find(".plan-title")).to have_text "Labrador"
      expect(find(".plan-allowance")).to have_text "Up to 1,000 Reviews"
      expect(find(".plan-price")).to have_text "$99 month"
    end

    within(plans[4]) do
      expect(find(".plan-title")).to have_text "Husky"
      expect(find(".plan-allowance")).to have_text "Up to 3,000 Reviews"
      expect(find(".plan-price")).to have_text "$199 month"
    end

    within(plans[5]) do
      expect(find(".plan-title")).to have_text "Great Dane"
      expect(find(".plan-allowance")).to have_text "Up to 10,000 Reviews"
      expect(find(".plan-price")).to have_text "$299 month"
    end
  end

  scenario "user with a subscription views account page" do
    user = create(:user, stripe_customer_id: stripe_customer_id)
    create(:subscription, user: user)

    responses = [individual_subscription_response]
    stub_customer_find_request_with_subscriptions(
      stripe_customer_id,
      generate_subscriptions_response(responses),
    )

    sign_in_as(user)
    visit account_path

    within(".itemized-receipt") do
      expect(page).to have_text("Great Dane")
      expect(page).to have_text("$49")
    end
  end

  scenario "user with discounted-amount subscription views account page" do
    user = create(:user, stripe_customer_id: stripe_customer_id)
    create(:subscription, user: user)

    responses = [discounted_amount_subscription_response]
    stub_customer_find_request_with_subscriptions(
      stripe_customer_id,
      generate_subscriptions_response(responses),
    )

    sign_in_as(user)
    visit account_path

    within(".itemized-receipt") do
      expect(page).to have_text("Great Dane")
      expect(page).to have_text("$250")
    end
  end

  scenario "user with discounted-percentage subscription views account page" do
    user = create(:user, stripe_customer_id: stripe_customer_id)
    create(:subscription, user: user)

    responses = [discounted_percent_subscription_response]
    stub_customer_find_request_with_subscriptions(
      stripe_customer_id,
      generate_subscriptions_response(responses),
    )

    sign_in_as(user)
    visit account_path

    within(".itemized-receipt") do
      expect(page).to have_text("Great Dane")
      expect(page).to have_text("$24.50")
    end
  end

  scenario "user updates their email address", :js do
    email_address = "somebody.else@example.com"
    stub_customer_find_request
    stub_customer_update_request(email: email_address)

    sign_in_as(create(:user, :stripe))
    visit account_path
    user = user_on_page
    user.update(email_address)

    expect(user).to be_updated
  end

  private

  def stub_customer_find_request_with_subscriptions(customer_id, subscriptions)
    stub_request(:get, "#{stripe_base_url}/customers/#{customer_id}").
      with(headers: { "Authorization" => "Bearer #{ENV['STRIPE_API_KEY']}" }).
      to_return(status: 200, body: merge_customer_subscriptions(subscriptions))
  end

  def user_on_page
    UserOnPage.new
  end

  def generate_subscriptions_response(subscriptions)
    {
      "object" => "list",
      "total_count" => subscriptions.length,
      "has_more" => false,
      "url" => "/v1/customers/cus_2e3fqARc1uHtCv/subscriptions",
      "data" => subscriptions,
    }
  end

  def discounted_amount_subscription_response
    read_subscription_fixture("discounted_amount")
  end

  def discounted_percent_subscription_response
    read_subscription_fixture("discounted_percent")
  end

  def individual_subscription_response
    read_subscription_fixture("individual")
  end

  def private_subscription_response
    read_subscription_fixture("private")
  end

  def org_subscription_response
    read_subscription_fixture("org")
  end

  def read_subscription_fixture(fixture)
    file_path = "spec/support/fixtures/stripe_#{fixture}_subscription.json"
    JSON.parse(File.read(file_path))
  end

  def merge_customer_subscriptions(subscriptions)
    file_path = "spec/support/fixtures/stripe_customer_find.json"
    customer_response = File.read(file_path)
    customer = JSON.parse(customer_response)
    customer["subscriptions"] = subscriptions
    customer.to_json
  end
end
