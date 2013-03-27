class AddNameToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :name, :string, null: false
  end
end
