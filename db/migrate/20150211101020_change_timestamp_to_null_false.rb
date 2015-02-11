class ChangeTimestampToNullFalse < ActiveRecord::Migration
  def change

    change_column_null :repos, :created_at, false
    change_column_null :repos, :updated_at, false

    change_column_null :memberships, :created_at, false
    change_column_null :memberships, :updated_at, false
  end
end
