class Home
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def open_source_pricings
    open_source_repos.map { |pricing| present(pricing) }
  end

  def private_pricings
    private_repos.map { |pricing| present(pricing) }
  end

  private

  def present(pricing)
    PricingPresenter.new(pricing: pricing, user: user)
  end

  def pricings
    Pricing.all
  end

  def private_repos
    pricings.reject(&:open_source?)
  end

  def open_source_repos
    pricings.select(&:open_source?)
  end
end
