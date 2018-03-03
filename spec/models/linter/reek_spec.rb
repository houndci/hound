# frozen_string_literal: true

require "rails_helper"

describe Linter::Reek do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.rb foo.rake) }
    let(:not_lintable_files) { %w(foo.js) }
  end

  describe "#file_review" do
    it "is a new file review" do
      repo = instance_double("Repo", owner: nil)
      build = instance_double(
        "Build",
        commit_sha: "somesha",
        pull_request_number: 123,
        repo: repo,
      )
      commit_file = instance_double(
        "CommitFile",
        content: "code",
        filename: "lib/ruby.rb",
        patch: "patch",
      )
      file_review = instance_double("FileReview")
      hound_config = instance_double("HoundConfig")
      missing_owner = instance_double("MissingOwner")
      allow(FileReview).to receive(:create!).and_return(file_review)
      allow(MissingOwner).to receive(:new).and_return(missing_owner)
      allow(Resque).to receive(:enqueue)
      linter = Linter::Reek.new(build: build, hound_config: hound_config)

      expect(linter.file_review(commit_file)).to eq file_review
      expect(Resque).to have_received(:enqueue)
    end
  end

  describe "#name" do
    it "is the class name converted to a config-friendly format" do
      build = instance_double("Build")
      hound_config = instance_double("HoundConfig")
      linter = Linter::Reek.new(build: build, hound_config: hound_config)

      expect(linter.name).to eq "reek"
    end
  end
end
