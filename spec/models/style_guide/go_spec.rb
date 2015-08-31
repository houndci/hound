require "rails_helper"

describe StyleGuide::Go do
  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      style_guide = build_style_guide
      commit_file = build_commit_file(filename: "a.go")

      result = style_guide.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      style_guide = build_style_guide("config")
      commit_file = build_commit_file(filename: "a.go")
      allow(Resque).to receive(:enqueue)

      style_guide.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        GoReviewJob,
        filename: commit_file.filename,
        commit_sha: commit_file.sha,
        pull_request_number: commit_file.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "config",
      )
    end
  end

  describe "#file_included?" do
    context "when file is in Godeps/_workspace" do
      it "returns false" do
        commit_file = build_commit_file(filename: "Godeps/_workspace/foo/a.go")
        style_guide = build_style_guide

        expect(style_guide.file_included?(commit_file)).to eq false
      end
    end

    context "when file is rooted in a vendor/ directory" do
      it "returns false" do
        commit_file = build_commit_file(filename: "vendor/foo/a.go")
        style_guide = build_style_guide

        expect(style_guide.file_included?(commit_file)).to eq false
      end
    end

    context "when file is in a vendor/ directory" do
      it "returns false" do
        commit_file = build_commit_file(filename: "foo/vendor/bar/a.go")
        style_guide = build_style_guide

        expect(style_guide.file_included?(commit_file)).to eq false
      end
    end

    context "when file is not vendored" do
      it "returns true" do
        commit_file = build_commit_file(filename: "a.go")
        style_guide = build_style_guide

        expect(style_guide.file_included?(commit_file)).to eq true
      end
    end
  end

  private

  def build_style_guide(config = "config")
    build = build(:build)
    repo_config = double("RepoConfig", raw_for: config)
    StyleGuide::Go.new(
      repo_config: repo_config,
      build: build,
      repository_owner_name: "ralph",
    )
  end
end
