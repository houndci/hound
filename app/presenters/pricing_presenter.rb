class PricingPresenter
  delegate :allowance, :open_source?, :price, :title, to: :pricing

  def initialize(pricing:, user:)
    @pricing = pricing
    @user = user
  end

  def current?
    tier.current == pricing
  end

  def next?
    tier.next == pricing
  end

  def to_partial_path
    if open_source?
      "pricings/open_source"
    else
      "pricings/private"
    end
  end

  private

  attr_reader :pricing, :user

  def tier
    @_tier ||= Tier.new(user)
  end
end
