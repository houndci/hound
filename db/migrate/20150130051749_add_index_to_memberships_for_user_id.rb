class AddIndexToMembershipsForUserId < ActiveRecord::Migration
  def change
    remove_index :memberships, column: [:repo_id, :user_id]
    add_index :memberships, :repo_id
    add_index :memberships, :user_id
  end
end
