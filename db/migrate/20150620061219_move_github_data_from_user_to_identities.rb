class MoveGithubDataFromUserToIdentities < ActiveRecord::Migration
  def up
    insert_sql = <<-SQL
      INSERT INTO identities(user_id, username, provider, created_at, updated_at)
      SELECT users.id, users.github_username, 'github', NOW(), NOW()
      FROM users
    SQL

    ActiveRecord::Base.connection.execute(insert_sql)

    remove_column :users, :github_username
  end

  def down
    add_column :users, :github_username, :string, limit: 255

    update_sql = <<-SQL
      UPDATE users
      SET github_username = (SELECT username
                             FROM identities
                             WHERE user_id = users.id
                               AND provider = 'github')
    SQL

    ActiveRecord::Base.connection.execute(update_sql)

    change_column :users, :github_username, :string, null: false, limit: 255
  end
end
