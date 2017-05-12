require "rails_helper"

RSpec.describe Linter::SassLint do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.scss foo.sass) }
    let(:not_lintable_files) { %w(foo.css bar.html) }
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      linter = build_linter
      commit_file = build_commit_file(filename: "scss/styles.scss")

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedule a review job" do
      build = build(:build, commit_sha: "baa", pull_request_number: 23)
      linter = build_linter(build)
      stub_sass_config({})
      commit_file = build_commit_file(filename: "scss/styles.scss")
      allow(Resque).to receive(:enqueue)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        LintersJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "sass_lint",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "{}",
      )
    end
  end

  private

  def stub_sass_config(config = {})
    stubbed_sass_config = double(
      "SassConfig",
      content: config,
      serialize: config.to_s,
    )
    allow(Config::SassLint).to receive(:new).and_return(stubbed_sass_config)

    stubbed_sass_config
  end
end
