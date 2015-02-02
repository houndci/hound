class AddUniquenessOnFullGithubNameToRepos < ActiveRecord::Migration
  def change
    add_index :repos, :full_github_name, unique: true
  end
end
