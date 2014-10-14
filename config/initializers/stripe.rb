Stripe.api_key = ENV["STRIPE_API_KEY"]

# https://www.petekeen.net/stripe-webhook-event-cheatsheet#12
StripeEvent.configure do |events|
  events.subscribe "customer.subscription.deleted" do |event|
    RepoDeactivator.new(event.data.object.customer).deactivate_all
  end
end
