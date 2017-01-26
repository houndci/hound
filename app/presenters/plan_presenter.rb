class PlanPresenter
  extend Forwardable

  def_delegators :plan, :interval, :name

  def initialize(plan)
    @plan = plan
  end

  def description
    "#{name} (#{amount.format}/#{interval})"
  end

  private

  attr_reader :plan
  def_delegators :plan, :currency

  def amount
    Money.new(plan.amount, currency)
  end
end
