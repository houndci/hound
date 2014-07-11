class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.timestamps
      t.integer :user_id, null: false
      t.integer :repo_id, null: false
    end

    add_index :subscriptions, :repo_id, unique: true
  end
end
