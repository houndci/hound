require "rails_helper"

describe CompletedFileReviewJob do
  it "completes FileReview with violations" do
    file_review = create_file_review
    stub_build_report_run
    stub_pull_request
    stub_payload

    CompletedFileReviewJob.perform_now(attributes)

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

    CompletedFileReviewJob.perform_now(attributes)

    expect(BuildReport).to have_received(:run).with(
      pull_request: pull_request,
      build: build,
      token: Hound::GITHUB_TOKEN,
    )
    expect(Payload).to have_received(:new).with(build.payload)
    expect(PullRequest).
      to(have_received(:new).with(payload, Hound::GITHUB_TOKEN))
  end

  context "when build doesn't exist" do
    it "retries the job" do
      job = CompletedFileReviewJob.new
      allow(job).to receive(:retry_job)

      CompletedFileReviewJob.perform_now(job, attributes)

      expect(job).to have_received(:retry_job)
    end
  end

  context "when Resque process is killed" do
    it "enqueues job" do
      kill_exception = Resque::TermException.new(1)
      job = CompletedFileReviewJob.new
      allow(job).to receive(:perform).and_raise(kill_exception)
      allow(CompletedFileReviewJob.queue_adapter).to receive(:enqueue)

      CompletedFileReviewJob.perform_now(job, attributes)

      expect(AcceptOrgInvitationsJob.queue_adapter).
        to have_received(:enqueue).with(job)
    end
  end

  context "when there are two builds with the same commit_sha" do
    it "finds the correct build by pull request number" do
      create(:build, commit_sha: "abc123", pull_request_number: 1)
      correct_build = create(
        :build,
        commit_sha: "abc123",
        pull_request_number: 123,
      )
      create(
        :file_review,
        build: correct_build,
        filename: attributes.fetch("filename"),
      )
      stub_build_report_run
      pull_request = stub_pull_request
      stub_payload

      CompletedFileReviewJob.perform_now(attributes)

      expect(BuildReport).to have_received(:run).with(
        pull_request: pull_request,
        build: correct_build,
        token: Hound::GITHUB_TOKEN,
      )
    end
  end

  def attributes
    @attributes ||= {
      "filename" => "test.scss",
      "commit_sha" => "abc123",
      "pull_request_number" => 123,
      "patch" => File.read("spec/support/fixtures/patch.diff"),
      "violations" => [
        { "line" => 14, "message" => "woohoo" }
      ]
    }
  end

  def create_file_review
    build = build(
      :build,
      commit_sha: attributes.fetch("commit_sha"),
      pull_request_number: attributes.fetch("pull_request_number")
    )
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
