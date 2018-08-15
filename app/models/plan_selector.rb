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

  private

  attr_reader :user

  def repo_count
    @_repo_count ||= repos.size
  end

  def find_plan(count)
    plan_class.find_by(count: count)
  end

  def repos
    user.subscribed_repos
  end

  def plan_class
    if user.marketplace_subscriber?
      GitHubPlan
    else
      Plan
    end
  end
end
