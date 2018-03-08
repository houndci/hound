class CreateOwnerships < ActiveRecord::Migration[5.1]
  def change
    create_table :ownerships do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.references :owner, null: false, index: true, foreign_key: true
      t.timestamps
      t.index [:user_id, :owner_id], unique: true
    end
  end
end
