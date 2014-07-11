class RemoveUniqueIndexFromSubscriptionsForRepoId < ActiveRecord::Migration
  def change
    remove_index :subscriptions, column: :repo_id
    add_index :subscriptions, :repo_id
  end
end
