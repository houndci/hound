class AddHookIdToRepos < ActiveRecord::Migration[4.2]
  def change
    add_column :repos, :hook_id, :integer
  end
end
