class CreateViolations < ActiveRecord::Migration
  def up
    create_violations_table
    rename_column :builds, :violations, :violations_archive
    add_index :violations, :build_id
  end

  def down
    rename_column :builds, :violations_archive, :violations
    drop_table :violations
  end

  private

  def create_violations_table
    create_table :violations do |t|
      t.timestamps null: false

      t.integer :build_id, null: false
      t.string :filename, null: false
      t.integer :patch_position
      t.integer :line_number
      t.text :messages, array: true, default: [], null: false
    end
  end
end
