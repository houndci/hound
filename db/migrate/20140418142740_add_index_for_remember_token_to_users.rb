class AddIndexForRememberTokenToUsers < ActiveRecord::Migration
  def change
    add_index :users, :remember_token
  end
end
