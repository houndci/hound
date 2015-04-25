class CreateFileReviews < ActiveRecord::Migration
  def change
    create_table :file_reviews do |t|
      t.belongs_to :build, index: true, foreign_key: true, null: false
      t.datetime :completed_at

      t.timestamps null: false
    end
  end
end
