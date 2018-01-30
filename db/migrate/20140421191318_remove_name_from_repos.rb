class RemoveNameFromRepos < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :repos, :name
  end

  def self.down
    add_column :repos, :name, :string
  end
end
