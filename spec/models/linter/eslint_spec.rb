require "rails_helper"

describe Linter::Eslint do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.es6 foo.js foo.jsx foo.vue) }
    let(:not_lintable_files) { %w(foo.js.coffee) }
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      commit_file = build_commit_file(filename: "lib/a.js")
      linter = build_linter

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      stub_eslint_config(content: {})
      commit_file = build_commit_file(filename: "lib/a.js")
      linter = build_linter(build)
      allow(EslintReviewJob).to receive(:perform_async)

      linter.file_review(commit_file)

      expect(EslintReviewJob).to have_received(:perform_async).with(
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "eslint",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "{}",
        linter_version: nil,
      )
    end
  end

  describe "#file_included?" do
    context "when file does not match any ignore patterns" do
      it "returns true" do
        stub_eslint_config
        linter = build_linter(nil, Linter::Eslint::IGNORE_FILENAME => "foo.js")
        commit_file = double("CommitFile", filename: "bar.js")

        expect(linter.file_included?(commit_file)).to eq true
      end
    end

    context "when file matches an ignore pattern" do
      it "returns false" do
        stub_eslint_config
        ignore_file_content = <<~EOS
          app/javascripts/**/*.js
          vendor/*
        EOS
        linter = build_linter(
          nil,
          Linter::Eslint::IGNORE_FILENAME => ignore_file_content,
        )
        commit_file1 = double(
          "CommitFile",
          filename: "app/javascripts/foo.js",
        )
        commit_file2 = double(
          "CommitFile",
          filename: "vendor/javascripts/bar/baz.js",
        )

        expect(linter.file_included?(commit_file1)).to be false
        expect(linter.file_included?(commit_file2)).to be false
      end
    end
  end

  def stub_eslint_config(content: {}, excluded_paths: [])
    stubbed_eslint_config = double(
      "EslintConfig",
      content: content,
      excluded_paths: excluded_paths,
      serialize: content.to_s,
    )
    allow(Config::Eslint).to receive(:new).and_return(stubbed_eslint_config)

    stubbed_eslint_config
  end

  def raw_hound_config
    <<~EOS
      eslint:
        enabled: true
        config_file: config/.eslintrc
    EOS
  end
end
