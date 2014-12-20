class InactivateReposWithoutPrivacyOrOrgInfo < ActiveRecord::Migration
  def up
    sql = <<-SQL
      UPDATE "repos"
        SET "active" = 'f'
        WHERE
          "active" IS true
          AND
          ("private" OR "in_organization" IS NULL)
    SQL

    ActiveRecord::Base.connection.execute(sql)
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
