require "rails_helper"

describe Linter::Scss do
  describe ".can_lint?" do
    context "given an .scss file" do
      it "returns true" do
        result = Linter::Scss.can_lint?("foo.scss")

        expect(result).to eq true
      end
    end

    context "given a non-scss file" do
      it "returns false" do
        result = Linter::Scss.can_lint?("foo.css")

        expect(result).to eq false
      end
    end
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      linter = build_linter
      commit_file = build_commit_file(filename: "lib/a.scss")

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      linter = build_linter(build)
      stub_scss_config("config")
      commit_file = build_commit_file(filename: "lib/a.scss")
      allow(Resque).to receive(:enqueue)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        ScssReviewJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "config"
      )
    end
  end

  def stub_scss_config(config = "config")
    stubbed_scss_config = double("ScssConfig", content: config)
    allow(Config::Scss).to receive(:new).and_return(stubbed_scss_config)

    stubbed_scss_config
  end
end
