class AddGithubIdUniquenessOnRepos < ActiveRecord::Migration
  def up
    remove_uniqueness(:full_github_name)
    add_uniqueness(:github_id)
  end

  def down
    remove_uniqueness(:github_id)
    add_uniqueness(:full_github_name)
  end

  private

  def remove_uniqueness(column)
    remove_index :repos, column
    add_index :repos, column
  end

  def add_uniqueness(column)
    remove_index :repos, column
    add_index :repos, column, unique: true
  end
end
