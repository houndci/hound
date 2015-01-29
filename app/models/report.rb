class Report
  def self.north_star
    generate_report("North Star") do |week|
      <<-SQL
        SELECT COUNT(distinct repos.id)
        FROM repos
        JOIN builds ON builds.repo_id = repos.id
        WHERE builds.created_at >= '#{week}'
        AND builds.created_at < '#{week + 7.days}'
      SQL
    end
  end

  def self.users
    generate_report("Users") do |week|
      <<-SQL
        SELECT COUNT(*)
        FROM users
        WHERE created_at >= '#{week}'
        AND created_at < '#{week + 7.days}'
      SQL
    end
  end

  def self.builds
    generate_report("Builds") do |week|
      <<-SQL
        SELECT COUNT(*)
        FROM builds
        WHERE created_at >= '#{week}'
        AND created_at < '#{week + 7.days}'
      SQL
    end
  end

  def self.subscriptions
    generate_report("Subscriptions") do |week|
      <<-SQL
        SELECT COUNT(*)
        FROM subscriptions
        WHERE deleted_at IS NULL
        AND created_at >= '#{week}'
        AND created_at < '#{week + 7.days}'
      SQL
    end
  end

  def self.cancellations
    generate_report("Subscriptions") do |week|
      <<-SQL
        SELECT COUNT(*)
        FROM subscriptions
        WHERE deleted_at IS NOT NULL
        AND created_at >= '#{week}'
        AND created_at < '#{week + 7.days}'
      SQL
    end
  end

  def self.generate_report(title)
    puts "#{title}:"

    weeks.each do |week|
      sql = yield week
      results = Repo.connection.execute(sql).first
      puts "#{week}: #{results["count"]}"
    end

    puts "\n\n"
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
end
