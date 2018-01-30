class AddPullRequestInfoToBuilds < ActiveRecord::Migration[4.2]
  def change
    add_column :builds, :pull_request_number, :integer
    add_column :builds, :commit_sha, :string
  end
end
