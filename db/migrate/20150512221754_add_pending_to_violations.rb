class AddPendingToViolations < ActiveRecord::Migration
  def change
    add_column :violations, :pending, :boolean, default: false, null: false
  end
end
