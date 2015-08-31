require "rails_helper"

describe StyleGuide::Scss do
  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      style_guide = build_style_guide
      commit_file = build_commit_file(filename: "lib/a.scss")

      result = style_guide.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      style_guide = build_style_guide("config")
      commit_file = build_commit_file(filename: "lib/a.scss")
      allow(Resque).to receive(:enqueue)

      style_guide.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        ScssReviewJob,
        filename: commit_file.filename,
        commit_sha: commit_file.sha,
        pull_request_number: commit_file.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "config"
      )
    end
  end

  describe "#file_included?" do
    it "returns true" do
      style_guide = build_style_guide

      expect(style_guide.file_included?(double)).to eq true
    end
  end

  private

  def build_style_guide(config = "config")
    repo_config = double("RepoConfig", raw_for: config)
    build = build(:build)
    StyleGuide::Scss.new(
      repo_config: repo_config,
      build: build,
      repository_owner_name: "ralph",
    )
  end
end
