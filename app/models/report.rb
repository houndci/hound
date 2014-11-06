class Report
  def self.north_star
    format "North Star" do
      weeks.each do |week|
        weekly_activity_sql = <<-SQL
          SELECT COUNT(distinct repos.id)
          FROM repos
          JOIN builds ON builds.repo_id = repos.id
          WHERE builds.created_at >= '#{week}'
          AND builds.created_at < '#{week + 7.days}'
        SQL

        generate_output(weekly_activity_sql, week)
      end
    end
  end

  def self.users
    format "Users" do
      weeks.each do |week|
        new_users_by_week_sql = <<-SQL
          SELECT COUNT(*)
          FROM users
          WHERE created_at >= '#{week}'
          AND created_at < '#{week + 7.days}'
        SQL

        generate_output(new_users_by_week_sql, week)
      end
    end
  end

  def self.builds
    format "Builds" do
      weeks.each do |week|
        builds_by_week_sql = <<-SQL
          SELECT COUNT(*)
          FROM builds
          WHERE created_at >= '#{week}'
          AND created_at < '#{week + 7.days}'
        SQL

        generate_output(builds_by_week_sql, week)
      end
    end
  end

  def self.subscriptions
    format "Subscriptions" do
      weeks.each do |week|
        subscriptions_by_week_sql = <<-SQL
          SELECT COUNT(*)
          FROM subscriptions
          WHERE deleted_at IS NULL
          AND created_at >= '#{week}'
          AND created_at < '#{week + 7.days}'
        SQL

        generate_output(subscriptions_by_week_sql, week)
      end
    end
  end

  def self.cancellations
    format "Cancellations" do
      weeks.each do |week|
        cancellations_by_week_sql = <<-SQL
          SELECT COUNT(*)
          FROM subscriptions
          WHERE deleted_at IS NOT NULL
          AND created_at >= '#{week}'
          AND created_at < '#{week + 7.days}'
        SQL

        generate_output(cancellations_by_week_sql, week)
      end
    end
  end

  def self.weeks
    series_sql = <<-SQL
      SELECT date_trunc('week', series)::date week
      FROM generate_series('2013-12-23', CURRENT_DATE, '1 week'::interval) series
    SQL

    Repo.connection.execute(series_sql).map do |result|
      Date.parse(result["week"])
    end
  end

  def self.generate_output(sql, week)
    results = Repo.connection.execute(sql).first
    puts "#{week}: #{results["count"]}"
  end

  def self.format(report_title)
    puts "#{report_title}:"
    yield
    puts "\n\n"
  end
end
