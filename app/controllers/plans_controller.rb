class PlansController < ApplicationController
  def index
    @plans = ActiveModel::ArraySerializer.new(
      Plan.all,
      each_serializer: PlanSerializer,
      scope: current_user,
    )
    @repo = Repo.find(plan_params[:repo_id])
  end

  private

  def plan_params
    params.permit(:repo_id)
  end
end
