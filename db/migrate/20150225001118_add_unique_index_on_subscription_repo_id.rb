class AddUniqueIndexOnSubscriptionRepoId < ActiveRecord::Migration
  def change
    remove_index :subscriptions, column: :repo_id
    add_index :subscriptions, :repo_id,
      unique: true, where: "deleted_at IS NULL"
  end
end
