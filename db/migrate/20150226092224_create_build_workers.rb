class CreateBuildWorkers < ActiveRecord::Migration
  def change
    create_table :build_workers do |t|
      t.belongs_to :build, null: false
      t.datetime :completed_at
      t.timestamps null: false
    end

    add_foreign_key :build_workers, :builds
  end
end
