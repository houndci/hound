namespace :reports do
  desc 'Prints out weekly activity, which is the number of repos that had builds during the week.'
  task activity: :environment do
    series_sql = <<-SQL
select date_trunc('week', series)::date week
from generate_series('2013-12-23', CURRENT_DATE, '1 week'::interval) series
    SQL

    weeks = Repo.connection.execute(series_sql).map {|result| Date.parse(result['week'])}

    weeks.each do |week|
      weekly_activity_sql = <<-SQL
select count(distinct repos.id)
from repos
join builds on builds.repo_id = repos.id
where builds.created_at >= '#{week}'
and builds.created_at < '#{week + 7.days}'
      SQL

      weekly_activity = Repo.connection.execute(weekly_activity_sql).first

      puts "#{week}: #{weekly_activity['count']}"
    end
  end
end
