require "rails_helper"

describe CompletedFileReviewJob do
  it "is retryable" do
    expect(RepoSynchronizationJob.new).to be_a(Retryable)
  end

  it "queue_as high" do
    expect(RepoSynchronizationJob.new.queue_name).to eq("high")
  end

  describe "perform" do
    it "calls `CompleteFileReview`" do
      allow(CompleteFileReview).to receive(:call)

      CompletedFileReviewJob.perform_now(attributes)

      expect(CompleteFileReview).to have_received(:call).with(attributes)
    end

    context "when build doesn't exist" do
      it "enqueues job with a 30 second delay" do
        allow(CompleteFileReview).to receive(:call).
          and_raise(ActiveRecord::RecordNotFound)

        expect_any_instance_of(CompletedFileReviewJob).
          to(receive(:retry_job).with(wait: 30.seconds))

        CompletedFileReviewJob.perform_now(attributes)
      end
    end
  end

  let(:attributes) do
    {
      filename: "test.scss",
      commit_sha: "abc123",
      pull_request_number: 123,
      patch: File.read("spec/support/fixtures/patch.diff"),
      violations: [line: 14, message: "woohoo"],
    }
  end
end
