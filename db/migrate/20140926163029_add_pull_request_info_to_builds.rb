class AddPullRequestInfoToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :pull_request_number, :integer
    add_column :builds, :commit_sha, :string
  end
end
