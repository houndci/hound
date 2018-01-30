class DropDelayedJobsTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :delayed_jobs
  end
end
