require "rails_helper"

describe Linter::ErbLint do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(app/foo.erb public/bar.html.erb) }
    let(:not_lintable_files) { %w(foo.html foo.rb) }
  end

  describe "#file_review" do
    it "returns a saved, incomplete file review" do
      linter = build_linter
      commit_file = build_commit_file(filename: "foo.erb")

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      allow(Resque).to receive(:enqueue)
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      linter = build_linter(build)
      commit_file = build_commit_file(filename: "foo.erb")

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        LintersJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "erb_lint",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: {}.to_yaml,
        linter_version: nil,
      )
    end
  end
end
