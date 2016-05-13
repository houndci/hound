class AddLinterNameToFileReviews < ActiveRecord::Migration
  def up
    add_column :file_reviews, :linter_name, :string
  end

  def down
    remove_column :file_reviews, :linter_name
  end
end
