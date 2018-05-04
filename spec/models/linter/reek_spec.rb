require "rails_helper"

RSpec.describe Linter::Reek do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.rb foo.rake) }
    let(:not_lintable_files) { %w(foo.js) }
  end

  describe "#file_review" do
    it "schedules a file review" do
      commit_file = build_commit_file(filename: "lib/foo.rb")
      linter = build_linter
      allow(Resque).to receive(:enqueue)

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
      expect(Resque).to have_received(:enqueue)
    end
  end

  describe "#name" do
    it "is the class name converted to a config-friendly format" do
      linter = build_linter

      expect(linter.name).to eq "reek"
    end
  end
end
