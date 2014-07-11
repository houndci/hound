class AddStripeSubscriptionIdToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :stripe_subscription_id, :string, null: false
  end
end
