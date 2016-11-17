class MonthlyLineItem
  vattr_initialize :subscription

  def subtotal_in_dollars
    amount_in_dollars
  end

  private

  def amount_in_dollars
    amount = (@subscription.plan_amount - discounted_amount) / 100
    amount * discounted_percent_multiplier
  end

  def discounted_percent_multiplier
    1.0 - (discounted_percent / 100)
  end

  def discounted_amount
    coupon.amount_off || 0
  end

  def discounted_percent
    (coupon.percent_off || 0).to_f
  end

  def discount
    @subscription.discount || PaymentGatewayCustomer::NoDiscount.new
  end

  def coupon
    if discount.coupon.valid
      discount.coupon
    else
      PaymentGatewayCustomer::NoCoupon.new
    end
  end
end
