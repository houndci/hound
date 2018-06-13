class AddStripeSubscriptionIdToOwners < ActiveRecord::Migration[5.1]
  def change
    add_column :owners, :stripe_subscription_id, :string
  end
end
