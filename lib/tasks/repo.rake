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
end
