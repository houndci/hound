class AddRepos < ActiveRecord::Migration
  def up
    create_table :repos do |t|
      t.integer :github_id, null: false
      t.boolean :active, null: false, default: false
    end

    add_index :repos, :github_id, unique: true
  end

  def down
    drop_table :repos
  end
end
