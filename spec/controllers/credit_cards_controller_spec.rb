require "rails_helper"

describe CreditCardsController, "#update" do
  context "when credit card is updated" do
    it "responds with 200" do
      card_token = "cardtoken"
      customer = double("PaymentGatewayCustomer", update_card: true)
      allow(PaymentGatewayCustomer).to receive(:new).and_return(customer)
      stub_sign_in(create(:user))

      put :update, card_token: card_token, format: :json

      expect(response).to have_http_status(:success)
      expect(customer).to have_received(:update_card).with(card_token)
    end
  end

  context "when credit card fails to update" do
    it "responds with 422" do
      request_credit_card_update_and_fail

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "captures exception" do
      allow(Raven).to receive(:capture_exception)

      request_credit_card_update_and_fail

      expect(Raven).to have_received(:capture_exception).
        with(kind_of(CreditCardsController::CreditCardUpdateFailed))
    end
  end

  def request_credit_card_update_and_fail
    customer = double("PaymentGatewayCustomer", update_card: false)
    allow(PaymentGatewayCustomer).to receive(:new).and_return(customer)
    stub_sign_in(create(:user))

    put :update, card_token: "cardtoken", format: :json
  end
end
