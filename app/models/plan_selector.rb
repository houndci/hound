class PlanSelector
  BULK_ID = "bulk".freeze

  def initialize(user:, repo: nil)
    @user = user
    @repo = repo || user.first_available_repo
  end

  def current_plan
    if marketplace_plan?
      plans.detect { |plan| plan.id == marketplace_plan_id }
    else
      plans.detect { |plan| plan.id == user.payment_gateway_subscription.plan }
    end
  end

  def upgrade?
    if marketplace_plan?
      !!(next_plan && next_plan.allowance > current_plan.allowance)
    else
      current_plan.open_source?
    end
  end

  def next_plan
    find_plan_by_active_repo_count(active_repo_count.succ)
  end

  def previous_plan
    find_plan_by_active_repo_count(active_repo_count.pred)
  end

  def marketplace_plan?
    marketplace_plan_id.present?
  end

  def plans
    plan_class::PLANS.map { |plan| plan_class.new(**plan) }
  end

  private

  attr_reader :user, :repo

  def find_plan_by_active_repo_count(active_repo_count)
    plans.detect do |plan|
      plan.range.include? active_repo_count
    end
  end

  def plan_class
    if marketplace_plan?
      GitHubPlan
    else
      MeteredStripePlan
    end
  end

  def marketplace_plan_id
    repo&.owner&.marketplace_plan_id
  end

  def active_repo_count
    user.subscribed_repos.size
  end
end
