# frozen_string_literal: true

require "rails_helper"

describe Linter::Remark do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.md foo.markdown) }
    let(:not_lintable_files) { %w(foo.txt) }
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      commit_file = build_commit_file(filename: "lib/a.md")
      linter = build_linter

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      stub_remark_config(content: {})
      commit_file = build_commit_file(filename: "lib/a.md")
      allow(Resque).to receive(:enqueue)
      linter = build_linter(build)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        LintersJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "remark",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "{}",
      )
    end
  end

  def stub_remark_config(content: "")
    stubbed_remark_config = double(
      "RemarkConfig",
      content: content,
      serialize: content.to_s,
    )
    allow(Config::Remark).to receive(:new).and_return(stubbed_remark_config)

    stubbed_remark_config
  end

  def raw_hound_config
    <<~EOS
      remark:
        enabled: true
        config_file: config/.remarkrc
    EOS
  end
end
