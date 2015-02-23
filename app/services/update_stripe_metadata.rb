class UpdateStripeMetadata
  def self.run
    Repo.joins(:subscription).find_each do |repo|
      subscription = repo.subscription
      payment_gateway_customer = PaymentGatewayCustomer.new(
        subscription.user
      ).customer

      stripe_subscription = payment_gateway_customer.subscriptions.retrieve(
        subscription.stripe_subscription_id
      )

      if stripe_subscription
        stripe_subscription.metadata = { repo_id: repo.id }
        stripe_subscription.save
      end
    end
  end
end
