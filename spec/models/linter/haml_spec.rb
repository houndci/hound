require "rails_helper"

describe Linter::Haml do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.haml) }
    let(:not_lintable_files) { %w(foo.rb) }
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      linter = build_linter
      commit_file = build_commit_file(filename: "lib/a.haml")

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      linter = build_linter(build)
      stub_haml_config({})
      commit_file = build_commit_file(filename: "lib/a.haml")
      allow(Resque).to receive(:enqueue)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        HamlReviewJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "haml",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "{}",
        linter_version: nil,
      )
    end
  end

  private

  def stub_haml_config(config = {})
    stubbed_haml_config = double(
      "HamlConfig",
      content: config,
      serialize: config.to_s,
    )
    allow(Config::Haml).to receive(:new).and_return(stubbed_haml_config)

    stubbed_haml_config
  end
end
