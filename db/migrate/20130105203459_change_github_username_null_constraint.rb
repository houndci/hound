class ChangeGithubUsernameNullConstraint < ActiveRecord::Migration
  def up
    change_column :users, :github_username, :string, null: false
  end

  def down
    change_column :users, :github_username, :string, null: true
  end
end
