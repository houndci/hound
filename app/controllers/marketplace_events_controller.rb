class MarketplaceEventsController < ApplicationController
  skip_before_action :authenticate, only: :create

  def create
    head :ok
  end
end
