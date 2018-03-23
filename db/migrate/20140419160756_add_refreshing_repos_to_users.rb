class AddRefreshingReposToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :refreshing_repos, :boolean, default: false
  end
end
