require "rails_helper"

RSpec.describe Linter::Coffeelint do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.coffee foo.coffee.erb foo.coffee.js) }
    let(:not_lintable_files) { %w(foo.js) }
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      linter = build_linter
      commit_file = build_commit_file(filename: "foo.coffee.js")

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      linter = build_linter(build)
      stub_coffeelint_config({})
      commit_file = build_commit_file(filename: "foo.coffee.js")
      allow(LintersJob).to receive(:perform_async)

      linter.file_review(commit_file)

      expect(LintersJob).to have_received(:perform_async).with(
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "coffeelint",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "{}",
        linter_version: nil,
        suggestions: false,
      )
    end
  end

  def stub_coffeelint_config(config = {})
    stubbed_config = instance_double(
      Config::Coffeelint,
      content: config,
      serialize: Config::Serializer.json(config),
    )
    allow(Config::Coffeelint).to receive(:new).and_return(stubbed_config)

    stubbed_config
  end
end
