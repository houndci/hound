class RemoveGithubTokenFromUsers < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :github_token
  end

  def down
    add_column :users, :github_token, :string
  end
end
