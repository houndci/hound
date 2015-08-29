require "rails_helper"

describe Linter::Python do
  describe ".can_lint?" do
    context "given a .python file" do
      it "returns true" do
        result = Linter::Python.can_lint?("foo.py")

        expect(result).to eq true
      end
    end

    context "given a non-python file" do
      it "returns false" do
        result = Linter::Python.can_lint?("foo.rb")

        expect(result).to eq false
      end
    end
  end

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
            filename: commit_file.filename,
            commit_sha: build.commit_sha,
            pull_request_number: build.pull_request_number,
            patch: commit_file.patch,
            content: commit_file.content,
            config: "config",
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
