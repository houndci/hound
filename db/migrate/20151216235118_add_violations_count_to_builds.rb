class AddViolationsCountToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :violations_count, :integer
  end
end
