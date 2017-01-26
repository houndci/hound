class Charge
  extend Forwardable

  def_delegators :charge, :currency, :description, :id, :source, :status
  def_delegators :invoice, :subscription_plan, :subtotal, :total

  def initialize(charge)
    @charge = charge
  end

  def amount
    Money.new(charge.amount, currency)
  end

  def date
    created.to_date
  end

  def description
    subscription_plan.name
  end

  def line_items
    invoice.lines
  end

  def successful?
    status == 'succeeded'
  end

  private

  attr_reader :charge

  def created
    Time.at(charge.created)
  end

  def invoice
    RemoteInvoice.new(charge.invoice)
  end
end
