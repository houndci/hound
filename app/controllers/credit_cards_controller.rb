class CreditCardsController < ApplicationController
  class CreditCardUpdateFailed < StandardError; end

  respond_to :json

  def update
    customer = PaymentGatewayCustomer.new(current_user)

    if customer.update_card(params[:card_token])
      head 200
    else
      report_error
      head 422
    end
  end

  private

  def report_error
    exception = CreditCardUpdateFailed.new(
      "Credit card failed to update for user #{current_user.id}"
    )
    Raven.capture_exception(exception)
  end
end
