class AddUserIdToRepos < ActiveRecord::Migration[4.2]
  def change
    add_column :repos, :user_id, :integer, null: false
  end
end
