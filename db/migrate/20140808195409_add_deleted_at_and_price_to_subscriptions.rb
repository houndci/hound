class AddDeletedAtAndPriceToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :deleted_at, :datetime
    add_column :subscriptions, :price, :decimal, null: false, precision: 8, scale: 2, default: 0
  end
end
