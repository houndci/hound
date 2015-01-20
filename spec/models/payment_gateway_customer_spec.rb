require "spec_helper"

describe PaymentGatewayCustomer do
  describe "#update_card" do
    it "updates card" do
      new_card_token = "newcardtoken"
      user = build(:user, stripe_customer_id: stripe_customer_id)
      customer = PaymentGatewayCustomer.new(user)
      stub_customer_find_request
      update_request = stub_customer_update_request(new_card_token)

      customer.update_card(new_card_token)

      expect(update_request).to have_been_requested
    end
  end
end
