class PricingController < ApplicationController
  def index
    @plans = [
      {name: "Chihuahua", upto: 4, price: 49, current: true},
      {name: "Labrador", upto: 10, price: 99},
      {name: "Great Dane", upto: 30, price: 249},
    ]

    @repo = Repo.find(pricing_params[:repo_id])
  end

  def pricing_params
    params.permit(:repo_id)
  end
end
