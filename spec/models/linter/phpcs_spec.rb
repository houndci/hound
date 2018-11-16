require "rails_helper"

RSpec.describe Linter::Phpcs do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.php foo.html.php foo/bar.php) }
    let(:not_lintable_files) { %w(foo.php.html) }
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      commit_file = build_commit_file(filename: "lib/foo.php")
      linter = build_linter

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      raw_config = "<ruleset></ruleset>"
      stub_config(raw_config)
      commit_file = build_commit_file(filename: "lib/foo.php")
      allow(Resque).to receive(:enqueue)
      linter = build_linter(build)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        LintersJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "phpcs",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: raw_config,
        linter_version: nil,
      )
    end
  end

  def stub_config(content)
    instance_double("Config::Phpcs", content: content, serialize: content).
      tap { |config| allow(Config::Phpcs).to receive(:new).and_return(config) }
  end

  def raw_hound_config
    <<~YAML
      phpcs:
        enabled: true
        config_file: config/.phpcs.xml
    YAML
  end
end
