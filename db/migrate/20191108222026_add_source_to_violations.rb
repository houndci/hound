class AddSourceToViolations < ActiveRecord::Migration[5.1]
  def change
    add_column :violations, :source, :string
  end
end
