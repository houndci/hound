class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.string :username, null: false, limit: 255
      t.string :provider, null: false, limit: 255
      t.integer :user_id, null: false

      t.timestamps null: false
    end

    add_index :identities, [:user_id, :provider], unique: true
    add_foreign_key :identities, :users
  end
end
