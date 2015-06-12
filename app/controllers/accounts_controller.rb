class AccountsController < ApplicationController
  def show
    @account_page = AccountPage.new(
      repos: find_subscribed_repos,
      billable_email: current_user.billable_email
    )
  end

  def update
    customer = PaymentGatewayCustomer.new(current_user)

    respond_to do |format|
      format.json do
        if customer.update_email(new_billable_email)
          render json: updated_account_page
        else
          head :bad_gateway
        end
      end
    end
  end

  private

  def new_billable_email
    params.require(:billable_email)
  end

  def find_subscribed_repos
    current_user.subscribed_repos.order(:full_github_name)
  end

  def updated_account_page
    AccountPage.new(
      repos: find_subscribed_repos,
      billable_email: new_billable_email
    )
  end
end
