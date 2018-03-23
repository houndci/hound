class AddUniqueIndexForUuid < ActiveRecord::Migration[4.2]
  def change
    change_column_null :builds, :uuid, false
    add_index :builds, :uuid, unique: true
  end
end
