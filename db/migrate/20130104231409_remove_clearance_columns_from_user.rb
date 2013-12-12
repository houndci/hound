class RemoveClearanceColumnsFromUser < ActiveRecord::Migration
  def up
    remove_columns(
      :users,
      :email,
      :encrypted_password,
      :salt,
      :confirmation_token,
      :remember_token
    )
  end

  def down
    add_column :users, :email, :string
    add_column :users, :encrypted_password, :string, limit: 128
    add_column :users, :salt, :string, limit: 128
    add_column :users, :confirmation_token, :string, limit: 128
    add_column :users, :remember_token, :string, limit: 128
  end
end
