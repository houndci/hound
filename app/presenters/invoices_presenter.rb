class InvoicesPresenter
  include Enumerable
  extend Forwardable

  def_delegators :invoices, :each, :to_ary

  def initialize(collection)
    @collection = collection
  end

  private

  attr_reader :collection

  def invoices
    @_invoices ||= collection.map { |invoice| InvoicePresenter.new(invoice) }
  end
end
