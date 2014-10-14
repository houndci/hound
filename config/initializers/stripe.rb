Stripe.api_key = ENV["STRIPE_API_KEY"]

# https://www.petekeen.net/stripe-webhook-event-cheatsheet#12
StripeEvent.configure do |events|
  events.subscribe "customer.subscription.deleted" do |event|
    stripe_customer_id = event.data.object.customer
    DeactivatePaidRepos.run(stripe_customer_id)
  end
end
