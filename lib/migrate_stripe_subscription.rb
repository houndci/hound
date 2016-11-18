class MigrateStripeSubscription
  def initialize(customer)
    @customer = customer
  end

  def run
    if user
      stripe_subscriptions.each do |stripe_subscription|
        update_stripe(stripe_subscription)
        update_db(stripe_subscription.id)
      end

      delete_stripe_subscriptions(stripe_subscriptions)
    else
      log_unknown
    end
  end

  private

  attr_reader :customer

  def coupon
    "tiered_pricing_existing"
  end

  def current_tier
    user.current_tier
  end

  def customer_id
    customer.id
  end

  def delete_stripe_subscriptions(subscriptions)
    while subscriptions.has_more
      subscriptions.each(&:delete)
    end
  end

  def log_unknown
    Rails.logger.info(
      "Couldn't find User with 'stripe_customer_id'=#{customer_id}",
    )
  end

  def plan_id
    current_tier.id
  end

  def stripe_subscriptions
    customer.subscriptions.all(limit: 1)
  end

  def subscriptions
    user.subscriptions
  end

  def update_stripe(stripe_subscription)
    stripe_subscription.plan = plan_id
    stripe_subscription.coupon = coupon
    stripe_subscription.save
  end

  def update_db(id)
    subscriptions.each do |subscription|
      subscription.update_attribute(:stripe_subscription_id, id)
    end
  end

  def user
    User.find_by(stripe_customer_id: customer_id)
  end
end
