class PlansController < ApplicationController
  MARKETPLACE_URL = ENV.fetch(
    "MARKETPLACE_URL",
    "https://www.github.com/marketplace/hound"
  )

  helper_method :plan_selector

  def index
    @plans = ActiveModel::Serializer::CollectionSerializer.new(
      plan_selector.plans,
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
    @_plan_selector ||= PlanSelector.new(user: current_user, repo: repo)
  end

  def marketplace_upgrade_url
    if plan_selector.marketplace_plan?
      "#{MARKETPLACE_URL}/order/#{plan_selector.next_plan.slug}?account=#{repo.owner.name}"
    end
  end

  def repo
    @_repo ||= Repo.find(plan_params[:repo_id])
  end
end
