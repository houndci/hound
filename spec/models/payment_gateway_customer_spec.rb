require "rails_helper"

describe PaymentGatewayCustomer do
  describe "#update_card" do
    it "updates card" do
      new_card_token = "newcardtoken"
      user = build(:user, stripe_customer_id: stripe_customer_id)
      customer = PaymentGatewayCustomer.new(user)
      stub_customer_find_request
      update_request = stub_customer_update_request(card: new_card_token)

      customer.update_card(new_card_token)

      expect(update_request).to have_been_requested
    end
  end

  describe "#update_email" do
    it "updates customer email" do
      new_email = "new-email@example.com"
      user = build(:user, stripe_customer_id: stripe_customer_id)
      customer = PaymentGatewayCustomer.new(user)
      stub_customer_find_request
      update_request = stub_customer_update_request(email: new_email)

      customer.update_email(new_email)

      expect(update_request).to have_been_requested
    end

    context "when update request fails" do
      it "returns false" do
        new_email = "new-email@example.com"
        user = build(:user, stripe_customer_id: stripe_customer_id)
        customer = PaymentGatewayCustomer.new(user)
        stub_customer_find_request
        stub_failed_customer_update_request(email: new_email)

        customer = customer.update_email(new_email)

        expect(customer).to eq false
      end
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

  describe "#new with_customer" do
    it "returns a new instance with customer set" do
      user = build_stubbed(:user, stripe_customer_id: nil)
      customer = :customer

      payment_gateway_customer = PaymentGatewayCustomer.new(
        user,
        customer: customer,
      )

      expect(payment_gateway_customer.customer).to eq customer
    end
  end

  describe "#subscription" do
    context "when stripe_customer_id is present" do
      it "retrieves subscription data" do
        user = build_stubbed(:user, stripe_customer_id: stripe_customer_id)
        stub_customer_find_request_with_subscriptions

        payment_gateway_customer = PaymentGatewayCustomer.new(user)
        subscription = payment_gateway_customer.subscription

        expect(subscription.plan_amount).to eq 900
        expect(subscription.plan_name).to eq "Personal"
      end
    end
  end
end
