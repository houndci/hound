require "rails_helper"

describe Linter::Go do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.go) }
    let(:not_lintable_files) { %w(foo.rb) }
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
        linter_name: "go",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: {},
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
