class AddForeignKeyMemberships < ActiveRecord::Migration
  def change
    add_foreign_key :memberships, :users
    add_foreign_key :memberships, :repos
  end
end
