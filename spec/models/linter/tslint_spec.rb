require "rails_helper"

describe Linter::Tslint do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.ts foo.tsx) }
    let(:not_lintable_files) { %w(foo.js.coffee) }
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      commit_file = build_commit_file(filename: "lib/a.ts")
      linter = build_linter

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      stub_tslint_config(content: {})
      commit_file = build_commit_file(filename: "lib/a.ts")
      linter = build_linter(build)
      allow(LintersJob).to receive(:perform_async)

      linter.file_review(commit_file)

      expect(LintersJob).to have_received(:perform_async).with(
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "tslint",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "{}",
        linter_version: nil,
      )
    end
  end

  def stub_tslint_config(content: {}, excluded_paths: [])
    stubbed_tslint_config = double(
      "TslintConfig",
      content: content,
      excluded_paths: excluded_paths,
      serialize: content.to_s,
    )
    allow(Config::Tslint).to receive(:new).and_return(stubbed_tslint_config)

    stubbed_tslint_config
  end

  def raw_hound_config
    <<~EOS
      tslint:
        enabled: true
        config_file: config/tslint.json
    EOS
  end
end
