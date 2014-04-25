class AddPrivateToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :private, :boolean
  end
end
