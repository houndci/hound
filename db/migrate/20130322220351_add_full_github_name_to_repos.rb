class AddFullGithubNameToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :full_github_name, :string, null: false
  end
end
