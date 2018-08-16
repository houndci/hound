class PlanSelector
  BULK_ID = "bulk".freeze

  def initialize(user)
    @user = user
  end

  def current_plan
    find_plan(repo_count)
  end

  def next_plan
    find_plan(repo_count.succ)
  end

  def previous_plan
    find_plan(repo_count.pred)
  end

  def upgrade?
    current_plan != next_plan
  end

  def all
    plans.map { |plan| plan_type.new(plan) }
  end

  private

  attr_reader :user

  def repo_count
    @_repo_count ||= repos.size
  end

  def find_plan(count)
    found = plans.detect { |plan| plan.fetch(:range).include?(count) }
    plan_type.new(found)
  end

  def repos
    user.subscribed_repos
  end

  def plans
    plan_type::PLANS
  end

  def plan_type
    if user&.marketplace_subscriber?
      GitHubPlan
    else
      StripePlan
    end
  end
end
