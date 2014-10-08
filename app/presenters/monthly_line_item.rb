class MonthlyLineItem
  include ActionView::Helpers::NumberHelper

  def initialize(price, repos)
    @price = price
    @repos = repos
  end

  def title
    case @repos.first.subscription_price
    when 9
      "Private Personal Repos"
    when 12
      "Private Repos"
    when 24
      "Private Org Repos"
    end
  end

  def base_price
    "#{number_to_currency(@price, precision: 0)}/mo."
  end

  def quantity
    "x#{@repos.count}"
  end

  def subtotal
    number_to_currency(@repos.sum(&:subscription_price), precision: 0)
  end
end
