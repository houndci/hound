class PaymentGatewayCustomer
  attr_reader :user

  def initialize(user, customer: nil)
    @user = user
    @customer = customer
  end

  def email
    customer.email
  end

  def customer
    @customer ||= begin
      if user.stripe_customer_id.present?
        Stripe::Customer.retrieve(user.stripe_customer_id)
      else
        NoRecord.new
      end
    end
  end

  def find_or_create_subscription(plan:, repo_id:)
    subscriptions.detect { |subscription| subscription.plan == plan } ||
      create_subscription(plan: plan, metadata: { repo_ids: repo_id })
  end

  def subscription
    subscriptions.first || NoSubscription.new
  end

  def retrieve_subscription(subscription_id)
    PaymentGatewaySubscription.new(
      stripe_subscription: customer.subscriptions.retrieve(subscription_id),
      tier: tier,
    )
  end

  def update_card(card_token)
    customer.card = card_token
    customer.save
  end

  def update_email(email)
    customer.email = email
    customer.save
  rescue Stripe::APIError => e
    Raven.capture_exception(e)
    false
  end

  private

  def create_subscription(options)
    PaymentGatewaySubscription.new(
      stripe_subscription: customer.subscriptions.create(options),
      tier: tier,
    )
  end

  def default_card
    customer.cards.detect { |card| card.id == customer.default_card } ||
      BlankCard.new
  end

  def subscriptions
    customer.subscriptions.map do |subscription|
      PaymentGatewaySubscription.new(
        stripe_subscription: subscription,
        tier: tier,
      )
    end
  end

  def tier
    Tier.new(user)
  end

  class NoRecord
    def email
      ""
    end

    def cards
      []
    end

    def subscriptions
      NoSubscription.new
    end
  end

  class NoSubscription
    def retrieve(*_args)
      nil
    end

    def data
      []
    end

    def discount
      NoDiscount.new
    end

    def map
      []
    end

    def plan_amount
      0
    end

    def plan_name
      "basic"
    end

    def quantity
      1
    end
  end

  class BlankCard
  end

  class NoDiscount
    def coupon
      NoCoupon.new
    end
  end

  class NoCoupon
    def amount_off
      0
    end

    def percent_off
      0
    end

    def valid
      true
    end
  end
end
