class InvoicePresenter
  def initialize(invoice)
    @invoice = invoice
  end

  def amount
    invoice.amount.format
  end

  def date
    I18n.l(invoice.date, format: :long)
  end

  def description
    invoice.description || "No description"
  end

  def model_name
    Struct.new(:singular_route_key).new("invoice")
  end

  def line_items
    invoice.line_items.map { |item| LineItemPresenter.new(item) }
  end

  def persisted?
    true
  end

  def source
    "#{invoice.source.brand} #{invoice.source.last4}"
  end

  def status
    invoice.status.humanize
  end

  def subtotal
    invoice.subtotal
  end

  def total
    invoice.total
  end

  def to_model
    self
  end

  def to_partial_path
    if successful?
      "invoices/successful"
    else
      "invoices/unsuccessful"
    end
  end

  def to_s
    invoice.id
  end

  private

  attr_reader :invoice

  def successful?
    invoice.successful?
  end
end
