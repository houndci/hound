class AddStripeSubscriptionIdToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :stripe_subscription_id, :string, null: false
  end
end
