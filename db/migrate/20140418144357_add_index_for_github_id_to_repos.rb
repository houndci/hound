class AddIndexForGithubIdToRepos < ActiveRecord::Migration[4.2]
  def change
    add_index :repos, :github_id
  end
end
