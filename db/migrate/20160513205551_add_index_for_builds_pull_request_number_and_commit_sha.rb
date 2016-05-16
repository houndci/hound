class AddIndexForBuildsPullRequestNumberAndCommitSha < ActiveRecord::Migration
  def change
    add_index :builds, [:commit_sha, :pull_request_number]
  end
end
