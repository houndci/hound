class AddSourceToViolations < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_column :violations, :source, :string, algorithm: :concurrently
  end
end
