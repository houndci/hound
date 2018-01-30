class AddNameToRepos < ActiveRecord::Migration[4.2]
  def change
    add_column :repos, :name, :string, null: false
  end
end
