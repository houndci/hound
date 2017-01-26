class Charges
  include Enumerable

  def initialize(customer)
    @customer = customer
  end

  def each(&block)
    collection.each(&block)
  end

  def find(id)
    Charge.new(customer.charges.retrieve(id))
  end

  private

  attr_reader :customer

  def collection
    customer.charges.auto_paging_each.inject([]) do |charges, charge|
      charges = charges + [Charge.new(charge)]
    end
  end
end
