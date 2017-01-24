require "rails_helper"

describe Linter::Ruby do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.rb foo.rake) }
    let(:not_lintable_files) { %w(foo.js) }
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
        RubocopReviewJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "ruby",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "--- {}\n",
      )
    end
  end

  private

  def stub_ruby_config(config = {})
    stubbed_ruby_config = instance_double(
      Config::Ruby,
      content: config,
      serialize: Config::Serializer.yaml(config),
    )
    allow(Config::Ruby).to receive(:new).and_return(stubbed_ruby_config)

    stubbed_ruby_config
  end
end
