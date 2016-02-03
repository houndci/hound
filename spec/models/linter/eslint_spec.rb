require "rails_helper"

describe Linter::Eslint do
  describe ".can_lint?" do
    context "given an .es6 file" do
      it "returns true" do
        result = Linter::Eslint.can_lint?("foo.es6")

        expect(result).to eq true
      end
    end

    context "given an .es6.js file" do
      it "returns true" do
        result = Linter::Eslint.can_lint?("foo.es6.js")

        expect(result).to eq true
      end
    end

    context "given a .js file" do
      it "returns true" do
        result = Linter::Eslint.can_lint?("foo.js")

        expect(result).to eq true
      end
    end

    context "given a non-eslint file" do
      it "returns false" do
        result = Linter::Eslint.can_lint?("foo.js.coffee")

        expect(result).to eq false
      end
    end
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      commit_file = build_commit_file(filename: "lib/a.js")
      linter = build_linter

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      stub_eslint_config(content: {})
      commit_file = build_commit_file(filename: "lib/a.js")
      allow(Resque).to receive(:enqueue)
      linter = build_linter(build)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        EslintReviewJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "{}",
      )
    end
  end

  def stub_eslint_config(content: {})
    stubbed_eslint_config = double(
      "EslintConfig",
      content: content,
      serialize: content.to_s,
    )
    allow(Config::Eslint).to receive(:new).and_return(stubbed_eslint_config)

    stubbed_eslint_config
  end

  def raw_hound_config
    <<-EOS.strip_heredoc
      eslint:
        enabled: true
        config_file: config/.eslintrc
    EOS
  end
end
