require "rails_helper"

module Linter
  class Test < Base
    FILE_REGEXP = /.+\.yes\z/
  end
end


describe Linter::Test do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.yes) }
    let(:not_lintable_files) { %w(foo.no bar.nope) }
  end

  describe "#file_review" do
    context "when a linter version is not configured" do
      it "enqueues a job without the linter version" do
        build = build(:build, commit_sha: "abc123", pull_request_number: 123)
        hound_config = instance_double("HoundConfig", linter_version: nil)
        linter = build_linter(build: build, hound_config: hound_config)
        commit_file = build_commit_file(filename: "wat.txt")
        build_config = instance_double(
          "Config::Unsupported",
          serialize: "config",
        )
        allow(BuildConfig).to receive(:call).and_return(build_config)
        allow(LintersJob).to receive(:perform_async)

        linter.file_review(commit_file)

        expect(LintersJob).to have_received(:perform_async).with(
          hash_including(linter_version: nil),
        )
      end
    end

    context "when a linter version is configured" do
      it "enqueues a job with the linter version" do
        build = build(:build, commit_sha: "abc123", pull_request_number: 123)
        hound_config = instance_double("HoundConfig", linter_version: 1.0)
        linter = build_linter(build: build, hound_config: hound_config)
        commit_file = build_commit_file(filename: "wat.txt")
        build_config = instance_double(
          "Config::Unsupported",
          serialize: "config",
        )
        allow(BuildConfig).to receive(:call).and_return(build_config)
        allow(LintersJob).to receive(:perform_async)

        linter.file_review(commit_file)

        expect(LintersJob).to have_received(:perform_async).with(
          hash_including(linter_version: 1.0),
        )
      end
    end
  end

  describe "#file_included?" do
    it "returns true" do
      linter = build_linter

      expect(linter.file_included?(double)).to eq true
    end
  end

  describe "#enabled?" do
    context "when the hound config is enabled for the given language" do
      it "returns true" do
        hound_config = instance_double("HoundConfig", linter_enabled?: true)
        linter = build_linter(hound_config: hound_config)

        expect(linter).to be_enabled
      end
    end

    context "when the hound config is disabled for the given language" do
      it "returns false" do
        hound_config = instance_double("HoundConfig", linter_enabled?: false)
        linter = build_linter(hound_config: hound_config)

        expect(linter).not_to be_enabled
      end
    end
  end

  def build_linter(options = {})
    default_options = {
      hound_config: double("HoundConfig", enabled_for?: false),
      build: double("Build", repo: double("Repo")),
    }

    Linter::Test.new(**default_options.merge(options))
  end
end
