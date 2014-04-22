class AddEmailAddressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_address, :string
  end
end
