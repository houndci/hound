require "rails_helper"

describe Linter::Go do
  describe ".can_lint?" do
    context "given a .go file" do
      it "returns true" do
        result = Linter::Go.can_lint?("foo.go")

        expect(result).to eq true
      end
    end

    context "given a non-go file" do
      it "returns false" do
        result = Linter::Go.can_lint?("foo.rb")

        expect(result).to eq false
      end
    end
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      linter = build_linter
      commit_file = build_commit_file(filename: "a.go")

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      linter = build_linter(build)
      commit_file = build_commit_file(filename: "a.go")
      allow(Resque).to receive(:enqueue)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        GoReviewJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: Config::Go::DEFAULT_CONFIG,
      )
    end
  end

  describe "#file_included?" do
    context "when file is in Godeps/_workspace" do
      it "returns false" do
        commit_file = build_commit_file(filename: "Godeps/_workspace/foo/a.go")
        linter = build_linter

        expect(linter.file_included?(commit_file)).to eq false
      end
    end

    context "when file is rooted in a vendor/ directory" do
      it "returns false" do
        commit_file = build_commit_file(filename: "vendor/foo/a.go")
        linter = build_linter

        expect(linter.file_included?(commit_file)).to eq false
      end
    end

    context "when file is in a vendor/ directory" do
      it "returns false" do
        commit_file = build_commit_file(filename: "foo/vendor/bar/a.go")
        linter = build_linter

        expect(linter.file_included?(commit_file)).to eq false
      end
    end

    context "when file is not vendored" do
      it "returns true" do
        commit_file = build_commit_file(filename: "a.go")
        linter = build_linter

        expect(linter.file_included?(commit_file)).to eq true
      end
    end
  end
end
