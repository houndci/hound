class RemoveRepoLimitConstraintOnBulkCustomers < ActiveRecord::Migration
  def change
    change_column_null :bulk_customers, :repo_limit, true
  end
end
