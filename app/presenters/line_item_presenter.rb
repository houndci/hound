class LineItemPresenter
  extend Forwardable

  def_delegators :line_item, :currency, :quantity

  def initialize(line_item)
    @line_item = line_item
  end

  def amount
    Money.new(line_item.amount, currency)
  end

  def description
    "Subscription to #{plan.description}"
  end

  private

  attr_reader :line_item

  def plan
    PlanPresenter.new(line_item.plan)
  end
end
