class AddUniquenessConstraintToRepos < ActiveRecord::Migration
  def change
    remove_index :repos, :github_id
    add_index :repos, [:user_id, :github_id], unique: true
  end
end
