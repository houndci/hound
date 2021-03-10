require "rails_helper"

describe Linter::ScssLint do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.scss) }
    let(:not_lintable_files) { %w(foo.css) }
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      linter = build_linter
      commit_file = build_commit_file(filename: "lib/a.scss")

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      linter = build_linter(build)
      stub_scss_config({})
      commit_file = build_commit_file(filename: "lib/a.scss")
      allow(LintersJob).to receive(:perform_async)

      linter.file_review(commit_file)

      expect(LintersJob).to have_received(:perform_async).with(
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "scss_lint",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "{}",
        linter_version: nil,
        suggestions: false,
      )
    end
  end

  def stub_scss_config(config = {})
    stubbed_scss_config = instance_double(
      "Config::ScssLint",
      content: config,
      serialize: config.to_s,
    )
    allow(Config::ScssLint).to receive(:new).and_return(stubbed_scss_config)

    stubbed_scss_config
  end
end
