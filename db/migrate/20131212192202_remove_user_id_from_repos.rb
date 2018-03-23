class RemoveUserIdFromRepos < ActiveRecord::Migration[4.2]
  def up
    remove_column :repos, :user_id
  end

  def down
    add_column :repos, :user_id, :integer
  end
end
