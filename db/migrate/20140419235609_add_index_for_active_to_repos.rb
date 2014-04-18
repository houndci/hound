class AddIndexForActiveToRepos < ActiveRecord::Migration
  def change
    add_index :repos, :active
  end
end
