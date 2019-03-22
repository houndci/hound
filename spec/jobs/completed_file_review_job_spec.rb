require "rails_helper"

RSpec.describe CompletedFileReviewJob do
  describe "perform" do
    it "calls CompleteFileReview" do
      attributes = {
        filename: "test.scss",
        commit_sha: "abc123",
        pull_request_number: 123,
        patch: File.read("spec/support/fixtures/patch.diff"),
        violations: [line: 14, message: "woohoo"],
      }
      allow(CompleteFileReview).to receive(:call)

      CompletedFileReviewJob.perform_async(attributes)

      expect(CompleteFileReview).to have_received(:call).
        with(attributes.deep_stringify_keys)
    end
  end
end
