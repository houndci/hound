require "rails_helper"

describe Linter::Swift do
  describe ".can_lint?" do
    context "given a .swift file" do
      it "returns true" do
        result = Linter::Swift.can_lint?("foo.swift")

        expect(result).to eq true
      end
    end

    context "given a non-swift file" do
      it "returns false" do
        result = Linter::Swift.can_lint?("foo.c")

        expect(result).to eq false
      end
    end
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
      allow(Resque).to receive(:enqueue)
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      linter = build_linter(build)
      stub_swift_config("config")
      commit_file = build_commit_file(filename: "a.swift")

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        SwiftReviewJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "config",
      )
    end
  end

  def stub_swift_config(config = "config")
    stubbed_swift_config = double("SwiftConfig", content: config)
    allow(Config::Swift).to receive(:new).and_return(stubbed_swift_config)

    stubbed_swift_config
  end
end
