require "rails_helper"

feature "Account" do
  scenario "user without Stripe Customer ID" do
    user = create(:user, stripe_customer_id: nil)

    sign_in_as(user)
    visit account_path

    expect(page).not_to have_text("Update Credit Card")
  end

  scenario "user with Stripe Customer ID" do
    user = create(:user, stripe_customer_id: "123")
    stub_customer_find_request(user.stripe_customer_id)

    sign_in_as(user)
    visit account_path

    expect(page).to have_text("Update Credit Card")
  end

  scenario "user with multiple subscriptions views account page" do
    user = create(:user, stripe_customer_id: "1234")
    subscriptions_response = generate_subscriptions_response([
      individual_subscription_response,
      private_subscription_response,
      org_subscription_response,
    ])
    stub_customer_find_request_with_subscriptions(
      user.stripe_customer_id,
      subscriptions_response,
    )
    individual_repo = create(:repo, users: [user])
    create(:subscription, repo: individual_repo, user: user, price: 9)
    private_repo = create(:repo, users: [user])
    create(:subscription, repo: private_repo, user: user, price: 12)
    organization_repo = create(:repo, users: [user])
    create(:subscription, repo: organization_repo, user: user, price: 24)
    public_repo = create(:repo, users: [user])

    sign_in_as(user)
    visit account_path

    expect(page).to have_text("$45")
    expect(page).to have_text("Personal")
    expect(page).to have_text("Private")
    expect(page).to have_text("Organization")
    expect(page).to have_text(private_repo.name)
    expect(page).to have_text(individual_repo.name)
    expect(page).to have_text(organization_repo.name)
    expect(page).not_to have_text(public_repo.name)
  end

  scenario "user with discounted subscriptions views account page" do
    user = create(:user, stripe_customer_id: "1234")
    subscriptions_reponse = generate_subscriptions_response([
      discounted_amount_subscription_response,
      discounted_percent_subscription_response,
    ])
    stub_customer_find_request_with_subscriptions(
      user.stripe_customer_id,
      subscriptions_reponse,
    )

    sign_in_as(user)
    visit account_path

    expect(page).to have_text("$700")
    expect(page).to have_text("Bulk - Yearly")
    expect(page).to have_text("$250/mo")
    expect(page).to have_text("$500") # 2x Bulk - Yearly subscription
    expect(page).to have_text("Bulk - Monthly")
    expect(page).to have_text("$200/mo")
  end

  scenario "user sees paid repo usage" do
    user = create(:user)
    paid_repo = create(:repo, users: [user])
    paid_repo.builds << create_failed_build
    paid_repo.builds << create_failed_build
    paid_repo.builds << create(:build)
    create(:subscription, repo: paid_repo, user: user)

    sign_in_as(user)

    visit account_path

    expect(find('td.reviews-given')).to have_text("3");
    expect(find('td.violations-caught')).to have_text("2");
  end

  private

  def create_failed_build
    file_review = build(:file_review, violations: build_list(:violation, 1))
    create(:build, file_reviews: [file_review])
  end

  def stub_customer_find_request_with_subscriptions(customer_id, subscriptions)
    stub_request(:get, "#{stripe_base_url}/#{customer_id}").
      with(headers: { "Authorization" => "Bearer #{ENV['STRIPE_API_KEY']}" }).
      to_return(status: 200, body: merge_customer_subscriptions(subscriptions))
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
