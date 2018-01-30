class AddUtmSourceToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :utm_source, :string
  end
end
