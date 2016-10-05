class TieredSubscriptionsMigrator
  class NoSuchTierError < StandardError; end

  DISCOUNT_COUPON_ID = "tiered_pricing_existing".freeze

  def initialize(user)
    @user = user
  end

  def self.migrate!(user)
    new(user).migrate!
  end

  # only the first subscription is upgraded, since Stripe
  # will cancel all others when we upgrade one of them
  def migrate!
    new_tier_name = tier_for_repo_count(@user.subscriptions.count)
    raise NoSuchTierError unless new_tier_name

    @user.subscriptions.each_with_index do |subscription, idx|
      if idx.zero?
        stripe_sub = get_subscription_from_stripe(subscription.stripe_subscription_id)
        stripe_sub.plan = new_tier_name
        stripe_sub.coupon = DISCOUNT_COUPON_ID
        stripe_sub.save
      else
        subscription.delete
      end
    end
  end

  private

  def tier_for_repo_count(count)
    _range, new_tier_name = Subscription::TIERS.detect { |k,_v| k.include?(count) }

    new_tier_name
  end

  def get_subscription_from_stripe(id)
    Stripe::Subscription.retrieve(id)
  end
end
