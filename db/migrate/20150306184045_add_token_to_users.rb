class AddTokenToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :token, :string
  end
end
