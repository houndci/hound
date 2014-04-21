class RemoveNameFromRepos < ActiveRecord::Migration
  def self.up
    remove_column :repos, :name
  end

  def self.down
    add_column :repos, :name, :string
  end
end
