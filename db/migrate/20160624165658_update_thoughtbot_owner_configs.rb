class UpdateThoughtbotOwnerConfigs < ActiveRecord::Migration
  def up
    execute <<~SQL
      UPDATE
        owners
      SET
        config_repo = 'thoughtbot/guides'
      WHERE
        owners.name in ('houndci', 'thoughtbot')
    SQL
  end

  def down
    execute <<~SQL
      UPDATE
        owners
      SET
        config_repo = 'houndci/legacy-config'
      WHERE
        owners.name in ('houndci', 'thoughtbot')
    SQL
  end
end
