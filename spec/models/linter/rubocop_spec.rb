require "rails_helper"

describe Linter::Rubocop do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.rb foo.rake) }
    let(:not_lintable_files) { %w(foo.js) }
  end

  describe ".can_lint?" do
    it "returns true for Gemfile" do
      expect(described_class.can_lint?("Gemfile")).to be(true)
    end

    it "returns false for Gemfile.lock" do
      expect(described_class.can_lint?("Gemfile.lock")).to be(false)
    end
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      linter = build_linter
      commit_file = build_commit_file(filename: "lib/a.rb")

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      linter = build_linter(build)
      stub_ruby_config({})
      commit_file = build_commit_file(filename: "lib/a.rb")
      allow(Resque).to receive(:enqueue)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        LintersJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "rubocop",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "--- {}\n",
        linter_version: nil,
      )
    end
  end

  private

  def stub_ruby_config(config = {})
    stubbed_ruby_config = instance_double(
      Config::Rubocop,
      content: config,
      serialize: Config::Serializer.yaml(config),
    )
    allow(Config::Rubocop).to receive(:new).and_return(stubbed_ruby_config)

    stubbed_ruby_config
  end
end
