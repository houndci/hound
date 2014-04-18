class AddRefreshingReposToUsers < ActiveRecord::Migration
  def change
    add_column :users, :refreshing_repos, :boolean, default: false
  end
end
