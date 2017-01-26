class InvoicesController < ApplicationController
  def index
    @invoices = InvoicesPresenter.new(current_user.invoices)
  end

  def show
    @invoice = InvoicePresenter.new(current_user.invoices.find(params[:id]))
  end
end
