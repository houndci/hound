require "rails_helper"

describe Linter::Shellcheck do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.sh foo.zsh foo.bash) }
    let(:not_lintable_files) { %w(foo.js) }
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      commit_file = build_commit_file(filename: "lib/a.sh")
      linter = build_linter

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      commit_file = build_commit_file(filename: "lib/a.sh")
      allow(Resque).to receive(:enqueue)
      linter = build_linter(build)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        LintersJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "shellcheck",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "--- {}\n",
        linter_version: nil,
      )
    end
  end
end
