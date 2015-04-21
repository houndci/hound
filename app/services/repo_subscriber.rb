class RepoSubscriber
  pattr_initialize :repo, :user, :card_token

  def self.subscribe(repo, user, card_token)
    new(repo, user, card_token).subscribe
  end

  def self.unsubscribe(repo, user)
    new(repo, user, nil).unsubscribe
  end

  def subscribe
    repo.subscription || create_subscription
  end

  def unsubscribe
    stripe_subscription = payment_gateway_customer.subscriptions.retrieve(
      repo.subscription.stripe_subscription_id
    )
    stripe_subscription.delete

    repo.subscription.destroy
  rescue => error
    report_exception(error)
    nil
  end

  private

  def create_subscription
    stripe_subscription = stripe_customer.subscriptions.create(
      plan: repo.plan_type,
      metadata: { repo_id: repo.id }
    )

    create_subscription_record(stripe_subscription.id)
  rescue => error
    report_exception(error)
    stripe_subscription.try(:delete)
    nil
  end

  def report_exception(error)
    Raven.capture_exception(
      error,
      extra: { user_id: user.id, repo_id: repo.id }
    )
  end

  def stripe_customer
    if user.stripe_customer_id.present?
      payment_gateway_customer
    else
      create_stripe_customer
    end
  end

  def payment_gateway_customer
    @payment_gateway_customer ||= PaymentGatewayCustomer.new(user).customer
  end

  def create_stripe_customer
    stripe_customer = Stripe::Customer.create(
      email: user.email_address,
      metadata: { user_id: user.id },
      card: card_token
    )

    user.update(stripe_customer_id: stripe_customer.id)

    stripe_customer
  end

  def create_subscription_record(stripe_subscription_id)
    repo.create_subscription!(
      user_id: user.id,
      stripe_subscription_id: stripe_subscription_id,
      price: repo.plan_price
    )
  end
end
