# frozen_string_literal: true

require "rails_helper"

describe Linter::Scss do
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
      allow(Resque).to receive(:enqueue)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        ScssReviewJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "scss",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "{}",
      )
    end
  end

  def stub_scss_config(config = {})
    stubbed_scss_config = double(
      "ScssConfig",
      content: config,
      serialize: config.to_s,
    )
    allow(Config::Scss).to receive(:new).and_return(stubbed_scss_config)

    stubbed_scss_config
  end
end
