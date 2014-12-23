class AddEnabledToRepos < ActiveRecord::Migration
  def up
    add_column :repos, :enabled, :boolean, default: false
    add_index :repos, :enabled
    execute("UPDATE repos SET enabled=active")
    change_column_null(:repos, :enabled, false)
  end

  def down
    remove_column :repos, :enabled
  end
end
