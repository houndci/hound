class AccountsController < ApplicationController
  def show
    @account_page = AccountPage.new(find_subscribed_repos)
  end

  def update
    if update_account
      render json: customer, status: :created
    else
      head 502
    end
  end

  private

  def find_subscribed_repos
    current_user.subscribed_repos.order(:full_github_name)
  end

  def account_params
    params[:account].permit(:card_token)
  end

  def update_account
    customer = PaymentGatewayCustomer.new(current_user).customer
    customer.card = account_params[:card_token]
    customer.save
  end
end
