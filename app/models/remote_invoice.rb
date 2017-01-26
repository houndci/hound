class RemoteInvoice
  def initialize(id)
    @id = id
  end

  def lines
    invoice.lines.all
  end

  def subscription_plan
    subscription.plan
  end

  def subtotal
    Money.new(invoice.subtotal, invoice.currency)
  end

  def total
    Money.new(invoice.total, invoice.currency)
  end

  private

  attr_reader :id

  def invoice
    @_invoice ||= Stripe::Invoice.retrieve(id)
  end

  def subscription
    RemoteSubscription.new(invoice.subscription)
  end
end
