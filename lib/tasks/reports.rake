namespace :reports do
  desc 'Prints out weekly activity, which is the number of repos that had builds during the week.'
  task activity: :environment do
    weeks.each do |week|
      weekly_activity_sql = <<-SQL
        select count(distinct repos.id)
        from repos
        join builds on builds.repo_id = repos.id
        where builds.created_at >= '#{week}'
        and builds.created_at < '#{week + 7.days}'
      SQL

      generate_output(weekly_activity_sql, week)
    end
  end

  task users: :environment do
    weeks.each do |week|
      new_users_by_week_sql = <<-SQL
        select count(*)
        from users
        where created_at >= '#{week}'
        and created_at < '#{week + 7.days}'
      SQL

      generate_output(new_users_by_week_sql, week)
    end
  end

  task builds: :environment do
    weeks.each do |week|
      builds_by_week_sql = <<-SQL
        select count(*)
        from builds
        where created_at >= '#{week}'
        and created_at < '#{week + 7.days}'
      SQL

      generate_output(builds_by_week_sql, week)
    end
  end

  desc 'Prints out running total of organizations and users count by week'
  task repos_per_account: :environment do
    weeks.each do |week|
      orgs_by_week_sql = <<-SQL
        SELECT COUNT(DISTINCT (REGEXP_SPLIT_TO_ARRAY(full_github_name, E'\/'))[1])
        FROM repos
        WHERE created_at < '#{week + 7.days}'
      SQL

      generate_output(orgs_by_week_sql, week)
    end
  end

  desc 'Prints out active repo count by organization and user'
  task org_repo_count: :environment do
    sql = <<-SQL
      SELECT DISTINCT ((REGEXP_SPLIT_TO_ARRAY(full_github_name, E'\/'))[1]) AS org_name,
      COUNT(github_id) as repo_count
      FROM repos
      WHERE active = true
      GROUP BY org_name
      ORDER BY repo_count DESC
    SQL

    Repo.connection.execute(sql).each do |result|
      puts "#{result['org_name']} - #{result['repo_count']}"
    end
  end

  def weeks
    series_sql = <<-SQL
      select date_trunc('week', series)::date week
      from generate_series('2013-12-23', CURRENT_DATE, '1 week'::interval) series
    SQL

    Repo.connection.execute(series_sql).map do |result|
      Date.parse(result['week'])
    end
  end

  def generate_output(sql, week)
    results = Repo.connection.execute(sql).first
    puts "#{week}: #{results['count']}"
  end
end
