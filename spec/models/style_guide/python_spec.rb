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
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      style_guide = build_style_guide("config", build)
      commit_file = build_commit_file

      style_guide.file_review(commit_file)

      expect(Resque).to have_received(:push).with(
        "python_review",
        {
          class: "review.PythonReviewJob",
          args: [
            commit_file.filename,
            build.commit_sha,
            build.pull_request_number,
            commit_file.patch,
            commit_file.content,
            "config",
          ],
        }
      )
    end
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
      patch: "patch",
    )
  end
end
