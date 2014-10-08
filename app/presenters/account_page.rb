class AccountPage
  include ActionView::Helpers::NumberHelper

  attr_reader :repos

  def initialize(repos)
    @repos = repos
  end

  def monthly_line_items
    group_similarly_priced_repos.map do |price, repos|
      MonthlyLineItem.new(price, repos)
    end
  end

  def total_monthly_cost
    number_to_currency(
      @repos.inject(0) { |sum, repo| sum += repo.subscription_price },
      precision: 0
    )
  end

  private

  def group_similarly_priced_repos
    similarly_priced_repos = Hash.new { |hash, key| hash[key] = [] }

    @repos.each do |repo|
      similarly_priced_repos[repo.subscription_price] << repo
    end

    similarly_priced_repos
  end
end
