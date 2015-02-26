class CreateBuildWorkers < ActiveRecord::Migration
  def change
    create_table :build_workers do |t|
      t.belongs_to :build
      t.datetime :completed_at
      t.timestamps null: false
    end
  end
end
