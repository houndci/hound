class AddIndexForCreatedAtToBuilds < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index(:builds, "DATE(created_at)", algorithm: :concurrently)
  end
end
