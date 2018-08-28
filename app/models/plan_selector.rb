class PlanSelector
  BULK_ID = "bulk".freeze

  def initialize(user, repo: nil)
    @user = user
    @repo = repo
  end

  def current_plan
    if marketplace_plan?
      plans.detect do |plan|
        plan.id == marketplace_plan_id
      end
    else
      plans.detect do |plan|
        plan.range.include? active_repo_count
      end
    end
  end

  def upgrade?
    current_plan != next_plan
  end

  def next_plan
    find_plan_by_active_repo_count(active_repo_count.succ)
  end

  def previous_plan
    find_plan_by_active_repo_count(active_repo_count.pred)
  end

  def all
    plans.map { |plan| plan_type.new(plan) }
  end

  def marketplace_plan?
    marketplace_plan_id.present? || marketplace_subscriber?
  end

  private

  attr_reader :user, :repo

  def find_plan_by_active_repo_count(active_repo_count)
    plans.detect do |plan|
      plan.range.include? active_repo_count
    end
  end

  def plans
    plan_type::PLANS.map { |plan| plan_type.new(plan) }
  end

  def plan_type
    if marketplace_plan?
      GitHubPlan
    else
      StripePlan
    end
  end

  def marketplace_plan_id
    repo&.owner&.marketplace_plan_id
  end

  def marketplace_subscriber?
    user.repos.joins(:owner).where.not(owners: { marketplace_plan_id: nil }).any?
  end

  # marketplace quotas are based on repo owner
  # stripe quotas are based on user
  def active_repo_count
    if marketplace_plan?
      repo.owner.active_private_repos_count
    else
      user.subscribed_repos.count
    end
  end
end
