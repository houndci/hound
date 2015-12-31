class AddAdminToMemberships < ActiveRecord::Migration
  def up
    add_column :memberships, :admin, :boolean

    execute "UPDATE memberships SET admin=true"

    change_column_default :memberships, :admin, false
    change_column_null :memberships, :admin, false
  end

  def down
    remove_column :memberships, :admin
  end
end
