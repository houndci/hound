require "rails_helper"

describe CompletedFileReviewJob do
  describe ".perform" do
    it "completes FileReview with violations" do
      file_review = create_file_review
      stub_build_report_run
      stub_pull_request
      stub_payload

      CompletedFileReviewJob.perform(attributes)

      file_review.reload
      expect(file_review).to be_completed
      expect(file_review.violations).to be_present
    end

    it "runs Build Report" do
      file_review = create_file_review
      build = file_review.build
      stub_build_report_run
      pull_request = stub_pull_request
      payload = stub_payload

      CompletedFileReviewJob.perform(attributes)

      expect(BuildReport).to have_received(:run).with(pull_request, build)
      expect(Payload).to have_received(:new).with(build.payload)
      expect(PullRequest).to(
        have_received(:new).with(payload, ENV.fetch("HOUND_GITHUB_TOKEN"))
      )
    end

    context "when build doesn't exist" do
      it "enqueues job" do
        allow(Resque).to receive(:enqueue)

        CompletedFileReviewJob.perform(attributes)

        expect(Resque).to(
          have_received(:enqueue).with(CompletedFileReviewJob, attributes)
        )
      end
    end

    context "when Resque process is killed" do
      it "enqueues job" do
        allow(Build).to(
          receive(:find_by!).and_raise(Resque::TermException.new(1))
        )
        allow(Resque).to receive(:enqueue)

        CompletedFileReviewJob.perform(attributes)

        expect(Resque).to(
          have_received(:enqueue).with(CompletedFileReviewJob, attributes)
        )
      end
    end
  end

  def attributes
    @attributes ||= {
      "filename" => "test.scss",
      "commit_sha" => "abc123",
      "patch" => File.read("spec/support/fixtures/patch.diff"),
      "violations" => [
        { "line" => 14, "message" => "woohoo" }
      ]
    }
  end

  def create_build
    @build ||= build(:build, commit_sha: attributes.fetch("commit_sha"))
  end

  def create_file_review
    build = build(:build, commit_sha: attributes.fetch("commit_sha"))
    create(:file_review, build: build, filename: attributes.fetch("filename"))
  end

  def stub_build_report_run
    allow(BuildReport).to receive(:run)
  end

  def stub_pull_request
    pull_request = double("PullRequest")
    allow(PullRequest).to receive(:new).and_return(pull_request)

    pull_request
  end

  def stub_payload
    payload = double("Payload")
    allow(Payload).to receive(:new).and_return(payload)

    payload
  end
end
