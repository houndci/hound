class CreateStyleConfig < ActiveRecord::Migration
  def change
    create_table :style_configs do |t|
      t.boolean :enabled, default: true, null: false
      t.string :language, null: false
      t.text :rules, null: false
      t.integer :owner_id, null: false
    end

    add_index :style_configs, [:owner_id, :language], unique: true
    add_foreign_key :style_configs, :owners
  end
end
