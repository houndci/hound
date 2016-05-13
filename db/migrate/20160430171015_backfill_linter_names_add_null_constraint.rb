class BackfillLinterNamesAddNullConstraint < ActiveRecord::Migration
  def up
    sql = <<-SQL
      UPDATE file_reviews
      SET linter_name = CASE
        WHEN filename ~* '\\.coffee(\\.js)?(\\.erb)?\\Z' THEN 'coffee_script'
        WHEN filename ~* '\\.go\\Z' THEN 'go'
        WHEN filename ~* '\\.haml\\Z' THEN 'haml'
        WHEN filename ~* '(\\.es6|\\.es6\\.js)\\Z' THEN 'eslint'
        WHEN filename ~* '\\.js\\Z' THEN 'jshint'
        WHEN filename ~* '(\\.md|\\.markdown)\\Z' THEN 'remark'
        WHEN filename ~* '\\.py\\Z' THEN 'python'
        WHEN filename ~* '\\.rb\\Z' THEN 'ruby'
        WHEN filename ~* '\\.scss\\Z' THEN 'scss'
        WHEN filename ~* '\\.swift\\Z' THEN 'swift'
        ELSE 'unsupported'
        END;
    SQL

    execute(sql)

    change_column_null :file_reviews, :linter_name, false
  end

  def down
    change_column_null :file_reviews, :linter_name, true

    sql = <<-SQL
      UPDATE file_reviews
      SET linter_name = null;
    SQL

    execute(sql)
  end
end
