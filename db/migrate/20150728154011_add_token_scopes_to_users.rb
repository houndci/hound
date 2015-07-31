class AddTokenScopesToUsers < ActiveRecord::Migration
  def up
    add_column :users, :token_scopes, :string
    execute "UPDATE users SET token_scopes = 'repo,user:email' WHERE token IS NOT NULL"
  end

  def down
    remove_column :users, :token_scopes
  end
end
