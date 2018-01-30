class AddUniquenessOnFullGithubNameToRepos < ActiveRecord::Migration[4.2]
  def change
    add_index :repos, :full_github_name, unique: true
  end
end
