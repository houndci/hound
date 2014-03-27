class RemoveGithubTokenFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :github_token
  end

  def down
    add_column :users, :github_token, :string
  end
end
