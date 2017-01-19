class Tier
  BULK_ID = "bulk".freeze

  def initialize(user)
    @user = user
  end

  def current
    select(count)
  end

  def full?
    has_repos? && pricing_changes?
  end

  def next
    select(succ)
  end

  def previous
    select(previous_repo_count)
  end

  private

  attr_reader :user

  def count
    repos.count
  end

  def has_repos?
    count.positive?
  end

  def previous_repo_count
    count.pred
  end

  def pricing_changes?
    self.next != current
  end

  def select(count)
    Pricing.find_by(count: count)
  end

  def succ
    count.succ
  end

  def repos
    user.subscribed_repos
  end
end
