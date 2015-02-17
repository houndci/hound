class BackfillTimestampsAddNullConstraints < ActiveRecord::Migration
  def up
    updates_sql = <<-SQL
      UPDATE memberships
        SET created_at = users.created_at
        FROM users
        WHERE memberships.user_id = users.id
        AND memberships.created_at is NULL;

      UPDATE memberships
        SET updated_at = users.updated_at
        FROM users
        WHERE memberships.user_id = users.id
        AND memberships.updated_at is NULL;

      UPDATE repos
        SET created_at = memberships.created_at
        FROM memberships
        WHERE repos.id = memberships.repo_id
        AND repos.created_at is NULL;

      UPDATE repos
        SET updated_at = memberships.updated_at
        FROM memberships
        WHERE repos.id = memberships.repo_id
        AND repos.updated_at is NULL;
    SQL

    remaining_updates = <<-SQL
      UPDATE repos
        SET created_at = (select current_timestamp)
        WHERE created_at is NULL;

      UPDATE repos
        SET updated_at = (select current_timestamp)
        WHERE updated_at is NULL;

      UPDATE memberships
        SET created_at = (select current_timestamp)
        WHERE created_at is NULL;

      UPDATE memberships
        SET updated_at = (select current_timestamp)
        WHERE updated_at is NULL;
    SQL

    ActiveRecord::Base.connection.execute(updates_sql)
    ActiveRecord::Base.connection.execute(remaining_updates)

    change_column_null :repos, :created_at, false
    change_column_null :repos, :updated_at, false

    change_column_null :memberships, :created_at, false
    change_column_null :memberships, :updated_at, false
  end

  def down
    change_column_null :repos, :created_at, true
    change_column_null :repos, :updated_at, true

    change_column_null :memberships, :created_at, true
    change_column_null :memberships, :updated_at, true
  end
end
