require "rails_helper"

describe Linter::Swiftlint do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.swift) }
    let(:not_lintable_files) { %w(foo.c) }
  end

  describe "#file_review" do
    it "returns a saved, incomplete file review" do
      linter = build_linter
      commit_file = build_commit_file(filename: "a.swift")

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      linter = build_linter(build)
      stub_swift_config
      commit_file = build_commit_file(filename: "a.swift")
      allow(LintersJob).to receive(:perform_async)

      linter.file_review(commit_file)

      expect(LintersJob).to have_received(:perform_async).with(
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "swiftlint",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "{}",
        linter_version: nil,
        suggestions: false,
      )
    end
  end

  describe "#file_included?" do
    context "when file does not match any ignore patterns" do
      it "returns true" do
        config = <<~YAML
          excluded:
            - some/dir
        YAML
        commit_file = build_commit_file(filename: "foo/bar/baz.swift")
        linter = build_linter
        stub_swift_config(config)

        expect(linter.file_included?(commit_file)).to eq true
      end
    end

    context "when file matches an ignore pattern" do
      it "returns false" do
        config = <<~YAML
          excluded:
            - some/dir/**/*.swift
            - foo/bar
        YAML
        commit_file1 = build_commit_file(filename: "foo/bar/baz.swift")
        commit_file2 = build_commit_file(filename: "some/dir/here/foo.swift")
        linter = build_linter
        stub_swift_config(config)

        expect(linter.file_included?(commit_file1)).to be false
        expect(linter.file_included?(commit_file2)).to be false
      end
    end
  end

  def stub_swift_config(config = "{}")
    stubbed_swift_config = instance_double(
      "Config::Swiftlint",
      content: YAML.safe_load(config),
      serialize: config,
    )
    allow(Config::Swiftlint).to receive(:new).and_return(stubbed_swift_config)

    stubbed_swift_config
  end
end
