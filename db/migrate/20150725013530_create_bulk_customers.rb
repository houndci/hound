class CreateBulkCustomers < ActiveRecord::Migration
  def change
    create_table :bulk_customers do |t|
      t.timestamps null: false

      t.string :org, null: false, index: { unique: true }
      t.string :description
      t.string :interval, null: false
      t.integer :repo_limit, null: false
      t.integer :current_repos, null: false, default: 0
      t.string :subscription_token
    end
  end
end
