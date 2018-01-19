class AddWhitelistedToOwners < ActiveRecord::Migration[5.0]
  def up
    add_column :owners, :whitelisted, :boolean, default: false, null: false

    execute <<~EOS
      UPDATE owners
      SET whitelisted = true
      FROM bulk_customers
      WHERE bulk_customers.org = owners.name
    EOS
  end

  def down
    remove_column :owners, :whitelisted
  end
end
