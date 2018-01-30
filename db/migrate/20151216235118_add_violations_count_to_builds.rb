class AddViolationsCountToBuilds < ActiveRecord::Migration[4.2]
  def change
    add_column :builds, :violations_count, :integer
  end
end
