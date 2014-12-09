namespace :membership do
  desc "Clean up duplicate memberships"
  task cleanup_duplicates: :environment do
    sql = <<-SQL
      DELETE FROM memberships m
      USING memberships m2
      WHERE
        m.user_id = m2.user_id AND
        m.repo_id = m2.repo_id AND
        m.id < m2.id
    SQL

    ActiveRecord::Base.connection.execute sql
  end
end
