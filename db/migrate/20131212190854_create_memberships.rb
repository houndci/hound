class CreateMemberships < ActiveRecord::Migration[4.2]
  def change
    create_table :memberships do |t|
      t.integer :user_id, null: false
      t.integer :repo_id, null: false
    end

    add_index :memberships, [:repo_id, :user_id]
  end
end
