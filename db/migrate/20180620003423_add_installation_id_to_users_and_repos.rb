class AddInstallationIdToUsersAndRepos < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :installation_ids, :integer, array: true, default: []
    add_column :repos, :installation_id, :integer
  end
end
