class RemoveStyleConfig < ActiveRecord::Migration
  def up
    drop_table :style_configs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
