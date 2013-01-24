class AddGithubTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :github_token, :string
  end
end
