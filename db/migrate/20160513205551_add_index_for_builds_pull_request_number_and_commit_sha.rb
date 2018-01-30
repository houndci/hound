class AddIndexForBuildsPullRequestNumberAndCommitSha < ActiveRecord::Migration[4.2]
  def change
    add_index :builds, [:commit_sha, :pull_request_number]
  end
end
