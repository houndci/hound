class MigrateStripeCustomers
  def self.run
    new.run
  end

  def run(customers = all_customers)
    customers.each { |customer| migrate_subscriptions_for(customer) }

    while customers.has_more
      customers = Stripe::Customers.all(
        limit: 100,
        starting_after: customers.data.last.id,
      )

      run(customers)
    end
  end

  private

  def all_customers
    Stripe::Customer.all(limit: 100)
  end

  def migrate_subscriptions_for(customer)
    MigrateStripeSubscription.new(customer).run
  end
end
