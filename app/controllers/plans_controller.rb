class PlansController < ApplicationController
  MARKETPLACE_URL = ENV.fetch(
    "MARKETPLACE_URL",
    "https://www.github.com/marketplace/hound"
  )

  helper_method :plan_selector

  def index
    # Do we need to add logic for Marketplace here too? Where is this used?
    @plans = ActiveModel::ArraySerializer.new(
      plan_selector.plans,
      each_serializer: PlanSerializer,
      scope: current_user,
    )
    @repo = repo
    @marketplace_upgrade_url = marketplace_upgrade_url

    # Should we be finding the current owner's plan based on repo and
    # basing upgrade/downgrade on that?
  end

  private

  def plan_params
    params.permit(:repo_id)
  end

  def plan_selector
    @plan_selector ||= PlanSelector.new(user: current_user, repo: repo)
  end

  def marketplace_upgrade_url
    # Should we include this in the serialized plans instead?
    if plan_selector.marketplace_plan?
      # Should we include the username or org name for upgrading on Marketplace?
      "#{MARKETPLACE_URL}/order/#{plan_selector.next_plan.slug}?account=#{repo.owner.name}"
    end
  end

  def repo
    @repo ||= Repo.find(plan_params[:repo_id])
  end
end
