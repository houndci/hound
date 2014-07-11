class AddIndexForUserId < ActiveRecord::Migration
  def change
    add_index :subscriptions, :user_id
  end
end
