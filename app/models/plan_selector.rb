class PlanSelector
  BULK_ID = "bulk".freeze

  def initialize(user:, repo: nil)
    @user = user || User.new
    @repo = repo
  end

  def current_plan
    if marketplace_plan?
      plans.detect do |plan|
        plan.id == marketplace_plan_id
      end
    else
      find_plan_by_active_repo_count(active_repo_count)
    end
  end

  def upgrade?
    !!(next_plan && next_plan.allowance > current_plan.allowance)
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
    plan_class::PLANS.map { |plan| plan_class.new(plan) }
  end

  private

  attr_reader :user

  def repo
    @repo || user.first_available_repo
  end

  def find_plan_by_active_repo_count(active_repo_count)
    plans.detect do |plan|
      plan.range.include? active_repo_count
    end
  end

  def plan_class
    if marketplace_plan?
      GitHubPlan
    else
      StripePlan
    end
  end

  def marketplace_plan_id
    repo&.owner&.marketplace_plan_id
  end

  def active_repo_count
    user.subscribed_repos.size
  end
end
