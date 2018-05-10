class MarketplacePlanSelector
  def initialize(owner)
    @owner = owner
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

  def upgrade_url
    "https://www.github.com/marketplace/hound/upgrade/#{next_plan.id}/#{owner.github_id}"
  end

  private

  attr_reader :owner

  def repo_count
    @_repo_count ||= owner.repos.where(private: true, active: true).count
  end

  def find_plan(count)
    MarketplacePlan.find_by(count: count)
  end
end
