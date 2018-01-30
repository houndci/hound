class AssociateUserToBuild < ActiveRecord::Migration[4.2]
  def change
    add_column :builds, :user_id, :integer
  end
end
