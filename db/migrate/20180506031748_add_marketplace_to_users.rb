class AddMarketplaceToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :marketplace, :boolean, default: false
  end
end
