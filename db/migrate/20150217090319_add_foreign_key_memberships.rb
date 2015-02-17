class AddForeignKeyMemberships < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute <<-SQL
      DELETE FROM memberships
      WHERE (repo_id NOT IN (SELECT id FROM repos))
    SQL

    add_foreign_key :memberships, :users
    add_foreign_key :memberships, :repos
  end

  def down
    remove_foreign_key :memberships, :users
    remove_foreign_key :memberships, :repos
  end
end
