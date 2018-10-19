# frozen_string_literal: true

require "rails_helper"

describe Linter::SlimLint do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.slim) }
    let(:not_lintable_files) { %w(foo.haml) }
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      linter = build_linter
      commit_file = build_commit_file(filename: "lib/a.slim")

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      linter = build_linter(build)
      stub_slim_lint_config
      commit_file = build_commit_file(filename: "lib/a.slim")
      allow(Resque).to receive(:enqueue)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        LintersJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "slim_lint",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "{}",
        linter_version: nil,
      )
    end
  end

  def stub_slim_lint_config(config = {})
    stubbed_slim_lint_config = instance_double(
      "Config::SlimLint",
      content: config,
      serialize: config.to_s,
    )
    allow(Config::SlimLint).to receive(:new).
      and_return(stubbed_slim_lint_config)

    stubbed_slim_lint_config
  end
end
