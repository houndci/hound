class RepoSubscriber
  def self.subscribe(repo, user, card_token)
    new(repo, user, card_token).subscribe
  end

  def self.unsubscribe(repo, user)
    new(repo, user, nil).unsubscribe
  end

  pattr_initialize :repo, :user, :card_token

  def subscribe
    stripe_customer = if user.stripe_customer_id
      customer = find_stripe_customer
      customer.card = card_token
      customer.save
    else
      create_stripe_customer
    end

    stripe_subscription = stripe_customer.subscriptions.create(plan: repo.plan)

    repo.create_subscription!(
      user_id: user.id,
      stripe_subscription_id: stripe_subscription.id,
      price: repo.price
    )
  rescue => error
    report_exception(error)
    stripe_subscription.try(:delete)
    nil
  end

  def unsubscribe
    stripe_customer = find_stripe_customer

    if stripe_customer
      stripe_subscription = stripe_customer.subscriptions.
        retrieve(repo.subscription.stripe_subscription_id)
      stripe_subscription.delete
    end

    repo.subscription.try(:destroy)
  rescue => error
    report_exception(error)
    nil
  end

  private

  def report_exception(error)
    Raven.capture_exception(
      error,
      extra: { user_id: user.id, repo_id: repo.id }
    )
  end

  def find_stripe_customer
    customer_id = user.stripe_customer_id

    if customer_id.present?
      Stripe::Customer.retrieve(customer_id)
    end
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
end
