class RemoveStyleConfig < ActiveRecord::Migration[4.2]
  def up
    drop_table :style_configs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
