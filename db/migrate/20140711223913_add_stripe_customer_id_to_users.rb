class AddStripeCustomerIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :stripe_customer_id, :string
  end
end
