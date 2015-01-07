class RemoveNullConstraintFromViolationsFileName < ActiveRecord::Migration
  def up
    change_column_default(:violations, :filename, nil)
    change_column_null(:violations, :filename, true)
  end

  def down
    change_column_default(:violations, :filename, "")
    change_column_null(:violations, :filename, false)
  end
end
