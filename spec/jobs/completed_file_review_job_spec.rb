require "rails_helper"

describe CompletedFileReviewJob do
  describe ".perform" do
    it "calls `CompleteFileReview`" do
      allow(CompleteFileReview).to receive(:run)

      CompletedFileReviewJob.perform(attributes)

      expect(CompleteFileReview).to have_received(:run).with(attributes)
    end

    context "when build doesn't exist" do
      it "enqueues job with a 30 second delay" do
        allow(CompleteFileReview).to receive(:run).
          and_raise(ActiveRecord::RecordNotFound)
        allow(Resque).to receive(:enqueue_in)

        CompletedFileReviewJob.perform(attributes)

        expect(Resque).to have_received(:enqueue_in).
          with(30, CompletedFileReviewJob, attributes)
      end
    end

    context "when Resque process is killed" do
      it "enqueues job" do
        allow(CompleteFileReview).to receive(:run).
          and_raise(Resque::TermException.new(1))
        allow(Resque).to receive(:enqueue)

        CompletedFileReviewJob.perform(attributes)

        expect(Resque).to have_received(:enqueue).
          with(CompletedFileReviewJob, attributes)
      end
    end
  end

  let(:attributes) do
    {
      "filename" => "test.scss",
      "commit_sha" => "abc123",
      "pull_request_number" => 123,
      "patch" => File.read("spec/support/fixtures/patch.diff"),
      "violations" => ["line" => 14, "message" => "woohoo"],
    }
  end
end
