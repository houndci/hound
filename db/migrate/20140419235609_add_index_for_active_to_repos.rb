class AddIndexForActiveToRepos < ActiveRecord::Migration[4.2]
  def change
    add_index :repos, :active
  end
end
