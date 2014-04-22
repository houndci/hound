class AddIndexForGithubIdToRepos < ActiveRecord::Migration
  def change
    add_index :repos, :github_id
  end
end
