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
    !!(next_plan && next_plan.allowance > current_plan.allowance)
  end

  def next_plan
    find_plan_by_active_repo_count(active_repo_count.succ)
  end

  def previous_plan
    find_plan_by_active_repo_count(active_repo_count.pred)
  end

  def all
    plans
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
    plan_class::PLANS.map { |plan| plan_class.new(plan) }
  end

  def plan_class
    if marketplace_plan?
      GitHubPlan
    else
      StripePlan
    end
  end

  def marketplace_plan_id
    owner_marketplace_plan_id || first_user_marketplace_plan_id
  end

  def owner_marketplace_plan_id
    repo&.owner&.marketplace_plan_id
  end

  def first_user_marketplace_plan_id
    first_repo_with_marketplace_owner = repos_with_marketplace_owner.first

    first_repo_with_marketplace_owner&.owner.marketplace_plan_id
  end

  # Is this only needed for the account page?
  def marketplace_subscriber?
    repos_with_marketplace_owner.any?
  end

  def repos_with_marketplace_owner
    if user
      user.repos.joins(:owner).where.not(owners: { marketplace_plan_id: nil })
    else
      []
    end
  end

  # marketplace quotas are based on repo owner
  # stripe quotas are based on user
  def active_repo_count
    if marketplace_plan? && repo
      repo.owner.active_private_repos_count
    else
      user.subscribed_repos.size
    end
  end
end
