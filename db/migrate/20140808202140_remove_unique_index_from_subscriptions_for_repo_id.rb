class RemoveUniqueIndexFromSubscriptionsForRepoId < ActiveRecord::Migration[4.2]
  def change
    remove_index :subscriptions, column: :repo_id
    add_index :subscriptions, :repo_id
  end
end
