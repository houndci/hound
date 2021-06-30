class PlansController < ApplicationController
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
      plan_selector.marketplace_upgrade_url
    end
  end

  def repo
    @_repo ||= Repo.find(plan_params[:repo_id])
  end
end
