require "rails_helper"

RSpec.describe CompleteFileReview do
  describe ".call" do
    it "completes FileReview with violations" do
      file_review = create_file_review
      allow(CompleteBuild).to receive(:call)

      CompleteFileReview.call(attributes)

      file_review.reload
      expect(file_review).to be_completed
      expect(file_review.violations.size).to eq 1
      expect(file_review.error).to eq attributes[:error]
    end

    it "runs completes the build" do
      file_review = create_file_review
      allow(CompleteBuild).to receive(:call)

      CompleteFileReview.call(attributes)

      expect(CompleteBuild).to have_received(:call).with(file_review.build)
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
          filename: attributes.fetch(:filename),
        )
        allow(CompleteBuild).to receive(:call)

        CompleteFileReview.call(attributes)

        expect(CompleteBuild).to have_received(:call).with(correct_build)
      end
    end

    context "when one of the file reviews is not complete" do
      it "does not complete build" do
        file_review = create_file_review
        create(:file_review, build: file_review.build)
        allow(CompleteBuild).to receive(:call)

        described_class.call(attributes)

        expect(CompleteBuild).not_to have_received(:call)
      end
    end
  end

  def attributes
    {
      filename: "test.scss",
      commit_sha: "abc123",
      pull_request_number: 123,
      patch: File.read("spec/support/fixtures/patch.diff"),
      violations: [line: 14, message: "woohoo", source: "debugger"],
      error: "Your linter config is invalid",
    }
  end

  def create_file_review
    build = build(
      :build,
      commit_sha: attributes.fetch(:commit_sha),
      pull_request_number: attributes.fetch(:pull_request_number),
    )
    create(:file_review, build: build, filename: attributes.fetch(:filename))
  end
end
