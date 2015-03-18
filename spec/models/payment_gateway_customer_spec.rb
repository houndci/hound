require "rails_helper"

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

  describe "#email" do
    it "returns customer email" do
      user = build_stubbed(:user, stripe_customer_id: stripe_customer_id)
      stub_customer_find_request
      payment_gateway_customer = PaymentGatewayCustomer.new(user)

      customer = payment_gateway_customer.customer
      expect(payment_gateway_customer.email).to eq customer.email
    end
  end

  describe "#card_last4" do
    context "when a customer has a card in stripe" do
      it "returns last 4 from the customers card" do
        user = build_stubbed(:user, stripe_customer_id: stripe_customer_id)
        stub_customer_find_request
        payment_gateway_customer = PaymentGatewayCustomer.new(user)

        expect(payment_gateway_customer.card_last4).to eq "4242"
      end
    end

    context "when a customer does not have a card in stripe" do
      it "returns a null object" do
        user = build_stubbed(:user, stripe_customer_id: nil)
        payment_gateway_customer = PaymentGatewayCustomer.new(user)

        expect(payment_gateway_customer.card_last4).to eq ""
      end
    end
  end

  describe "#customer" do
    context "when stripe_customer_id is present" do
      it "retrieve customer data" do
        user = build_stubbed(:user, stripe_customer_id: stripe_customer_id)
        stub_customer_find_request
        payment_gateway_customer = PaymentGatewayCustomer.new(user)

        expect(payment_gateway_customer.customer.id).to eq stripe_customer_id
      end
    end

    context "when stripe_customer_id is not present" do
      it "return null object" do
        user = build_stubbed(:user, stripe_customer_id: nil)
        payment_gateway_customer = PaymentGatewayCustomer.new(user)
        customer = payment_gateway_customer.customer

        expect(customer.email).to eq ""
        expect(customer.cards).to eq []
        expect(customer.subscriptions.retrieve).to eq nil
      end
    end

    it "is memoized" do
      user = build_stubbed(:user, stripe_customer_id: nil)
      payment_gateway_customer = PaymentGatewayCustomer.new(user)
      customer = payment_gateway_customer.customer

      expect(customer).to be payment_gateway_customer.customer
    end
  end
end
