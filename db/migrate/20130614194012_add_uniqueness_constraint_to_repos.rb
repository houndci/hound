class AddUniquenessConstraintToRepos < ActiveRecord::Migration
  def up
    remove_index :repos, :github_id
    add_index :repos, [:user_id, :github_id], unique: true
  end

  def down
    remove_index :repos, [:user_id, :github_id]
    add_index :repos, :github_id
  end
end
