namespace :repo do
  desc "Delete repos with no memberships"
  task remove_without_memberships: :environment do
    ActiveRecord::Base.connection.execute <<-SQL
      DELETE FROM repos
      WHERE id IN (
        SELECT repos.id FROM repos
        LEFT OUTER JOIN memberships on memberships.repo_id = repos.id
        LEFT OUTER JOIN subscriptions on subscriptions.repo_id = repos.id
        WHERE memberships.id IS NULL
        AND subscriptions.id is NULL
        AND repos.active = false
      )
    SQL
  end

  desc "Delete repos with duplicate github_ids"
  task remove_duplicate_github_ids: :environment do
    ActiveRecord::Base.connection.execute <<-SQL
      WITH del AS (
        SELECT
          id,
          row_number() OVER (
            PARTITION BY github_id ORDER BY active desc, id desc
          ) as rn
        FROM repos
      )
      DELETE FROM repos
      USING del
      WHERE repos.id = del.id AND del.rn > 1
    SQL
  end
end
