class Home
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def open_source_plans
    open_source_repos.map { |plan| present(plan) }
  end

  def private_plans
    private_repos.map { |plan| present(plan) }
  end

  private

  def present(plan)
    PlanPresenter.new(plan: plan, user: user)
  end

  def plans
    plan_selector.plans
  end

  def private_repos
    plans.reject(&:open_source?)
  end

  def open_source_repos
    plans.select(&:open_source?)
  end

  def plan_selector
    PlanSelector.new(user: user)
  end
end
