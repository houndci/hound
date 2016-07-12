class CreateBlacklistedPullRequests < ActiveRecord::Migration
  def change
    create_table :blacklisted_pull_requests do |t|
      t.string :full_repo_name, null: false
      t.integer :pull_request_number, null: false

      t.timestamps null: false
    end
  end
end
