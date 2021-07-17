class CreateSubscription
  pattr_initialize :owner

  def call
    if owner.stripe_subscription_id.blank?
    payment_gateway_subscription = payment_gateway_customer.
      retrieve_subscription(repo.subscription.stripe_subscription_id)
    end
  end

  private

  def payment_gateway_customer
    @_payment_gateway_customer ||= PaymentGatewayCustomer.new(owner)
  end
end
