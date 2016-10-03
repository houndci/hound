class AddConfigToOwner < ActiveRecord::Migration
  def up
    add_column :owners, :config_enabled, :boolean, null: false, default: false
    add_column :owners, :config_repo, :string

    execute << ~SQL
    UPDATE
    owners
    SET
    config_repo = 'houndci/legacy-config',
                  config_enabled = true
    FROM
    repos
    WHERE
    repos.owner_id = owners.id AND repos.active = true
    SQL

  end

  def down
    remove_column :owners, :config_enabled
    remove_column :owners, :config_repo
  end
end
