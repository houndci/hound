class MarketplacePlan
  include ActiveModel::Serialization

  PLANS = [
    { id: 1061, price: 0, range: 0..0, title: "Open Source" },
    { id: 1062, price: 49, range: 1..4, title: "Chihuahua" },
    { id: 1063, price: 149, range: 5..20, title: "Octodog" },
  ].freeze

  attr_reader :id, :price, :title

  def initialize(id:, range:, price:, title:)
    @id = id
    @range = range
    @price = price
    @title = title
  end

  def self.all
    PLANS.map { |plan| new(plan) }
  end

  def self.find_by(count:)
    found = PLANS.detect { |plan| plan.fetch(:range).include?(count) }
    new(found)
  end

  def ==(other)
    id == other.id
  end

  def allowance
    range.max
  end

  def open_source?
    price.zero?
  end

  private

  attr_reader :range
end
