class AccountPage
  def initialize(user)
    @user = user
  end

  def allowance
    current_plan.allowance
  end

  def billable_email
    user.billable_email
  end

  def monthly_line_item
    MonthlyLineItem.new(subscription)
  end

  def plan
    current_plan.title
  end

  def plans
    Plan.all.map do |plan|
      PlanPresenter.new(plan: plan, user: user)
    end
  end

  def remaining
    allowance - repo_count
  end

  def repos
    subscribed_repos.order(:name)
  end

  def subscription
    user.payment_gateway_subscription
  end

  def total_monthly_cost
    monthly_line_item.subtotal_in_dollars
  end

  private

  attr_reader :user

  def current_plan
    user.current_plan
  end

  def repo_count
    subscribed_repos.count
  end

  def subscribed_repos
    user.subscribed_repos
  end
end
