class AddUniqueConstraintToMemberships < ActiveRecord::Migration
  def self.up
    transaction do
      remove_duplicate_memberships

      add_index :memberships, [:user_id, :repo_id], unique: true
      remove_index :memberships, column: :user_id
    end
  end

  def self.down
    remove_index :memberships, [:user_id, :repo_id]
    add_index :memberships, :user_id
  end

  def remove_duplicate_memberships
    sql = <<-SQL
      DELETE FROM memberships m
      USING memberships m2
      WHERE
        m.user_id = m2.user_id AND
        m.repo_id = m2.repo_id AND
        m.id < m2.id
    SQL

    execute(sql)
  end
end
