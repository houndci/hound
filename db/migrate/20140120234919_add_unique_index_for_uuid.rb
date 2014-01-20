class AddUniqueIndexForUuid < ActiveRecord::Migration
  def change
    change_column_null :builds, :uuid, false
    add_index :builds, :uuid, unique: true
  end
end
