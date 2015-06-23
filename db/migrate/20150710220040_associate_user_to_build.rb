class AssociateUserToBuild < ActiveRecord::Migration
  def change
    add_column :builds, :user_id, :integer
  end
end
