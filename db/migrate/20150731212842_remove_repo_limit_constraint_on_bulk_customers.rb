class RemoveRepoLimitConstraintOnBulkCustomers < ActiveRecord::Migration[4.2]
  def change
    change_column_null :bulk_customers, :repo_limit, true
  end
end
