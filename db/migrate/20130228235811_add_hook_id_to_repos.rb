class AddHookIdToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :hook_id, :integer
  end
end
