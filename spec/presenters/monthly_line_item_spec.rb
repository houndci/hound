require "spec_helper"
require "stripe"
require "app/models/payment_gateway_subscription"
require "app/presenters/monthly_line_item"

RSpec.describe MonthlyLineItem do
  describe "#subtotal_in_dollars" do
    it "returns the amount in dollars" do
      coupon = double(
        "Stripe::Coupon",
        amount_off: 0,
        percent_off: 0,
        valid: true,
      )
      discount = double("Stripe::Discount", coupon: coupon)
      subscription = instance_double(
        "PaymentGatewaySubscription",
        discount: discount,
        plan_amount: 4900,
      )
      subtotal = 49.00
      item = MonthlyLineItem.new(subscription)

      expect(item.subtotal_in_dollars).to eq subtotal
    end
  end
end
