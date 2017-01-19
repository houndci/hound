class AccountsController < ApplicationController
  before_action :validate_billable_email, only: :update

  def show
    @account_page = AccountPage.new(current_user)
  end

  def update
    customer = PaymentGatewayCustomer.new(current_user)

    respond_to do |format|
      format.json do
        if customer.update_email(new_billable_email)
          head :ok
        else
          head :bad_gateway
        end
      end
    end
  end

  private

  def validate_billable_email
    unless EmailValidator.valid?(new_billable_email)
      error_message = I18n.t("account.billable_email.invalid")
      render json: { errors: [error_message] }, status: :unprocessable_entity
    end
  end

  def new_billable_email
    params[:billable_email]
  end
end
