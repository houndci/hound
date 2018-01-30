class AddForeignKeyMemberships < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key :memberships, :users
    add_foreign_key :memberships, :repos
  end
end
