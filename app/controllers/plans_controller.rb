class PlansController < ApplicationController
  MARKETPLACE_URL = "https://www.github.com/marketplace/hound"

  def index
    @plans = ActiveModel::ArraySerializer.new(
      plan_selector.all,
      each_serializer: PlanSerializer,
      scope: current_user,
    )
    @repo = repo
    @marketplace_upgrade_url = marketplace_upgrade_url
  end

  private

  def plan_params
    params.permit(:repo_id)
  end

  def plan_selector
    PlanSelector.new(current_user)
  end

  def marketplace_upgrade_url
    if current_user.marketplace_subscriber?
      # Should we include the username or org name for upgrading on Marketplace?
      "#{MARKETPLACE_URL}/order/#{current_user.next_plan.slug}?account=#{repo.owner.name}"
    end
  end

  def repo
    @repo ||= Repo.find(plan_params[:repo_id])
  end
end
