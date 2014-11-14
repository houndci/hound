Stripe.api_key = ENV["STRIPE_API_KEY"]

# https://www.petekeen.net/stripe-webhook-event-cheatsheet#12
StripeEvent.configure do |events|
  events.subscribe "customer.subscription.deleted" do |event|
    stripe_customer_id = event.data.object.customer
    RepoDeactivator.new(stripe_customer_id).deactivate_paid_repos
  end
end
