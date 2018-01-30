class AddIndexForUserId < ActiveRecord::Migration[4.2]
  def change
    add_index :subscriptions, :user_id
  end
end
