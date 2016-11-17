class PricingsController < ApplicationController
  def index
    @pricings = ActiveModel::ArraySerializer.new(
      Pricing.all,
      each_serializer: PricingSerializer,
      scope: current_user,
    )
    @repo = Repo.find(pricing_params[:repo_id])
  end

  private

  def pricing_params
    params.permit(:repo_id)
  end
end
