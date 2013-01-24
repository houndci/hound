class AddUserIdToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :user_id, :integer, null: false
  end
end
