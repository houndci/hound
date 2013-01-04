class AddGithubUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :github_username, :string
  end
end
