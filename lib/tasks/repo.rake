namespace :repo do
  desc 'Find 3,000 repos without privacy or organization information and update with info from GitHub'
  task backfill_privacy_and_organization: :environment do
    puts 'Finding repos ...'

    where_condition = <<-SQL
      (private IS NULL OR in_organization IS NULL)
    SQL

    repo_ids = Repo.where(where_condition).limit(3_000).pluck(:id)
    puts 'Scheduling RepoInformationJob jobs for repos ...'

    repo_ids.each do |repo_id|
      JobQueue.push(RepoInformationJob, repo_id)
    end

    puts 'Done scheduling jobs (max 3000). Rerun as necessary.'
  end

  desc "Delete repos with no memberships"
  task remove_without_memberships: :environment do
    ActiveRecord::Base.connection.execute <<-SQL
      DELETE FROM repos
      WHERE id IN (
        SELECT repos.id FROM repos
        LEFT OUTER JOIN memberships on memberships.repo_id = repos.id
        WHERE memberships.id IS NULL
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
