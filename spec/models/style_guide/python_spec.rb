require "rails_helper"

describe StyleGuide::Python do
  describe "#file_review" do
    it "returns a saved, incomplete file review" do
      style_guide = build_style_guide
      commit_file = build_commit_file

      result = style_guide.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      allow(Resque).to receive(:push)
      style_guide = build_style_guide("config")
      commit_file = build_commit_file

      style_guide.file_review(commit_file)

      expect(Resque).to have_received(:push).with(
        "python_review",
        {
          class: "review.PythonReviewJob",
          args: [
            commit_file.filename,
            commit_file.sha,
            commit_file.pull_request_number,
            commit_file.patch,
            commit_file.content,
            "config",
          ],
        }
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
    StyleGuide::Python.new(
      repo_config: repo_config,
      build: build(:build),
      repository_owner_name: "ralph",
    )
  end

  def build_commit_file
    line = double(
      "Line",
      changed?: true,
      content: "blah",
      number: 1,
      patch_position: 2,
    )
    double(
      "CommitFile",
      content: "codes",
      filename: "lib/a.py",
      line_at: line,
      sha: "abc123",
      patch: "patch",
      pull_request_number: 123,
    )
  end
end
