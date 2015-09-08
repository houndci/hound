require "rails_helper"

describe StyleGuide::Swift do
  describe "#file_review" do
    it "returns a saved, incomplete file review" do
      style_guide = build_style_guide
      commit_file = build_commit_file(filename: "a.swift")

      result = style_guide.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      allow(Resque).to receive(:enqueue)
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      style_guide = build_style_guide("config", build)
      commit_file = build_commit_file(filename: "a.swift")

      style_guide.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        SwiftReviewJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "config",
      )
    end
  end
end
