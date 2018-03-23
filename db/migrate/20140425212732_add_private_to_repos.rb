class AddPrivateToRepos < ActiveRecord::Migration[4.2]
  def change
    add_column :repos, :private, :boolean
  end
end
