class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.text :violations
      t.integer :repo_id

      t.timestamps null: false
    end

    add_index :builds, :repo_id
  end
end
