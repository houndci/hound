require "rails_helper"

describe StyleGuide::Scss do
  describe "#file_review" do
    it "returns an incompleted file review" do
      style_guide = build_style_guide
      file = build_file

      result = style_guide.file_review(file)

      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      allow(Resque).to receive(:enqueue)
      style_guide = build_style_guide("config")
      file = build_file

      style_guide.file_review(file)

      expect(Resque).to have_received(:enqueue).with(
        ScssReviewJob,
        filename: file.filename,
        commit_sha: file.sha,
        patch: file.patch_body,
        content: file.content,
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
    StyleGuide::Scss.new(repo_config, "ralph")
  end

  def build_file
    line = double(
      "Line",
      changed?: true,
      content: "blah",
      number: 1,
      patch_position: 2
    )
    double(
      "CommitFile",
      content: "codes",
      filename: "lib/a.scss",
      line_at: line,
      sha: "abc123",
      patch_body: "patchbody"
    )
  end
end
