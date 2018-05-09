require "rails_helper"

describe CompleteFileReview do
  describe ".call" do
    it "completes FileReview with violations" do
      file_review = create_file_review
      stub_build_report_run
      stub_pull_request
      stub_payload

      CompleteFileReview.call(attributes)

      file_review.reload
      expect(file_review).to be_completed
      expect(file_review.violations.size).to eq 1
      expect(file_review.build.violations_count).to eq 1
      expect(file_review.error).to eq attributes["error"]
    end

    it "runs completes the build" do
      file_review = create_file_review
      build = file_review.build
      stub_build_report_run
      pull_request = stub_pull_request
      payload = stub_payload

      CompleteFileReview.call(attributes)

      expect(CompleteBuild).to have_received(:call).with(
        pull_request: pull_request,
        build: build,
      )
      expect(Payload).to have_received(:new).with(build.payload)
      expect(PullRequest).
        to(have_received(:new).with(payload, Hound::GITHUB_TOKEN))
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

        CompleteFileReview.call(attributes)

        expect(CompleteBuild).to have_received(:call).with(
          pull_request: pull_request,
          build: correct_build,
        )
      end
    end
  end

  def attributes
    {
      "filename" => "test.scss",
      "commit_sha" => "abc123",
      "pull_request_number" => 123,
      "patch" => File.read("spec/support/fixtures/patch.diff"),
      "violations" => ["line" => 14, "message" => "woohoo"],
      "error" => "Your linter config is invalid",
    }
  end

  def create_file_review
    build = build(
      :build,
      commit_sha: attributes.fetch("commit_sha"),
      pull_request_number: attributes.fetch("pull_request_number"),
    )
    create(:file_review, build: build, filename: attributes.fetch("filename"))
  end

  def stub_build_report_run
    allow(CompleteBuild).to receive(:call)
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
