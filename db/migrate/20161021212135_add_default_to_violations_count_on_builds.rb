class AddDefaultToViolationsCountOnBuilds < ActiveRecord::Migration[4.2]
  def up
    change_column :builds, :violations_count, :integer, default: 0, null: false
  end

  def down
    change_column :builds, :violations_count, :integer, default: nil, null: true
  end
end
