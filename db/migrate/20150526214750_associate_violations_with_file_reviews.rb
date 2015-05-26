class AssociateViolationsWithFileReviews < ActiveRecord::Migration
  class Violation < ActiveRecord::Base
    belongs_to :file_review
  end
  class FileReview < ActiveRecord::Base; end

  def up
    add_column :file_reviews, :filename, :string, null: false
    add_column :violations, :file_review_id, :integer

    associate_violations_with_file_reviews

    change_column_null :violations, :file_review_id, false
    remove_column :violations, :build_id
    remove_column :violations, :filename

    add_index :violations, :file_review_id
    add_foreign_key :violations, :file_reviews, on_delete: :cascade
  end

  def down
    add_column :violations, :build_id, :integer
    add_column :violations, :filename, :string

    associate_violations_with_builds

    change_column_null :violations, :build_id, false
    change_column_null :violations, :filename, false
    remove_column :violations, :file_review_id
    remove_column :file_reviews, :filename, :string, null: false

    truncate :file_reviews
  end

  private

  def associate_violations_with_file_reviews
    execute <<-CREATE_FILE_REVIEWS
      INSERT INTO file_reviews (
        build_id,
        filename,
        completed_at,
        created_at,
        updated_at
      )
      WITH
      build_files AS (
        SELECT DISTINCT
          build_id,
          filename
        FROM
          violations
      )
      SELECT
        build_id,
        filename,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
      FROM
        build_files
    CREATE_FILE_REVIEWS

    execute <<-ASSOCIATE_VIOLATIONS_TO_FILE_REVIEWS
      UPDATE
        violations
      SET
        file_review_id = file_reviews.id,
        updated_at = CURRENT_TIMESTAMP
      FROM
        file_reviews
      WHERE
        file_reviews.build_id = violations.build_id AND
        file_reviews.filename = violations.filename
    ASSOCIATE_VIOLATIONS_TO_FILE_REVIEWS
  end

  def associate_violations_with_builds
    execute <<-ASSOCIATE_VIOLATIONS_TO_BUILDS
      UPDATE
        violations
      SET
        build_id = file_reviews.build_id,
        filename = file_reviews.filename,
        updated_at = CURRENT_TIMESTAMP
      FROM
        file_reviews
      WHERE
        file_reviews.id = violations.file_review_id
    ASSOCIATE_VIOLATIONS_TO_BUILDS
  end
end
