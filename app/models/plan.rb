class Plan
  include ActiveModel::Serialization

  attr_reader :id, :price, :title, :range

  def initialize(id:, range:, price:, title:)
    @id = id
    @range = range
    @price = price
    @title = title
  end

  def ==(other)
    other && id == other.id
  end

  def allowance
    range.max
  end

  def open_source?
    price.zero?
  end
end
