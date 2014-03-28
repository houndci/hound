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

      generate_output(weekly_activity_sql)
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

      generate_output(new_users_by_week_sql)
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

      generate_output(builds_by_week_sql)
    end
  end

  def weeks
    series_sql = <<-SQL
      select date_trunc('week', series)::date week
      from generate_series('2013-12-23', CURRENT_DATE, '1 week'::interval) series
    SQL

    Repo.connection.execute(series_sql).map {|result| Date.parse(result['week'])}
  end

  def generate_output
    weekly_activity = Repo.connection.execute(weekly_activity_sql).first
    puts "#{week}: #{weekly_activity['count']}"
  end
end
