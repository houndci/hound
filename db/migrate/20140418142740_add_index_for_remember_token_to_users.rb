class AddIndexForRememberTokenToUsers < ActiveRecord::Migration[4.2]
  def change
    add_index :users, :remember_token
  end
end
