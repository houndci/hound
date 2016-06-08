class AddConfigToOwner < ActiveRecord::Migration
  def up
    add_column :owners, :config_enabled, :boolean, null: false, default: false
    add_column :owners, :config_repo, :string

    Owner.update_all(config_enabled: true, config_repo: "houndci/legacy-config")
  end

  def down
    remove_column :owners, :config_enabled
    remove_column :owners, :config_repo
  end
end
