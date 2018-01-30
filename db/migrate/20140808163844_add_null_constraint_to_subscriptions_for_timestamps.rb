class AddNullConstraintToSubscriptionsForTimestamps < ActiveRecord::Migration[4.2]
  def change
    change_column_null :subscriptions, :created_at, false
    change_column_null :subscriptions, :updated_at, false
  end
end
