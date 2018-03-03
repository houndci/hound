class AddFullGitHubNameToRepos < ActiveRecord::Migration[4.2]
  def change
    add_column :repos, :full_github_name, :string, null: false
  end
end
