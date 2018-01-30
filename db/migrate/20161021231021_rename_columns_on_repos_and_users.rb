class RenameColumnsOnReposAndUsers < ActiveRecord::Migration[4.2]
  def change
    rename_column :repos, :full_github_name, :name

    rename_column :users, :email_address, :email
    rename_column :users, :github_username, :username
  end
end
