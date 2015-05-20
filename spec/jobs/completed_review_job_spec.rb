require "rails_helper"

describe CompletedReviewJob do
  describe ".perform" do
    it "adds violations to build" do
      build = create(:build, commit_sha: "abc123")

      CompletedReviewJob.perform(
        "repo_name" => build.repo.full_github_name,
        "filename" => "test.rb",
        "commit_sha" => build.commit_sha,
        "patch" => File.read("spec/support/fixtures/patch.diff"),
        "violations" => [
          "line" => 14,
          "message" => "Wat!!"
        ]
      )

      expect(build.reload).to have(1).violation
    end
  end
end
