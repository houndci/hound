class PaymentGatewayCustomer
  pattr_initialize :user

  def email
    customer.email
  end

  def card_last4
    default_card.last4
  end

  def card_brand
    default_card.brand
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

  def update_card(card_token)
    customer.card = card_token
    customer.save
  end

  private

  def default_card
    customer.cards.detect { |card| card.id == customer.default_card } ||
      BlankCard.new
  end

  class NoRecord
    def email
      ""
    end

    def cards
      []
    end
  end

  class BlankCard
    def last4
      ""
    end

    def brand
      ""
    end
  end
end
