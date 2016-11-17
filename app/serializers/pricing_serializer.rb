class PricingSerializer < ActiveModel::Serializer
  attributes :current, :name, :price, :allowance

  def current
    current_tier == object
  end

  def name
    object.title
  end

  private

  def current_tier
    scope.current_tier
  end
end
