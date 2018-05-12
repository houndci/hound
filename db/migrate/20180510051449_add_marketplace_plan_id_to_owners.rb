class AddMarketplacePlanIdToOwners < ActiveRecord::Migration[5.1]
  def change
    add_column :owners, :marketplace_plan_id, :integer
  end
end
