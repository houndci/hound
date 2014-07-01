module AccountsHelper
  def repos_total(repos)
    number_to_currency(repos.sum(&:subscription_price))
  end
end
