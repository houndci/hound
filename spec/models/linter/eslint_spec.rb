require "rails_helper"

describe Linter::Eslint do
  describe ".can_lint?" do
    context "given an .es6 file" do
      it "returns true" do
        result = Linter::Eslint.can_lint?("foo.es6")

        expect(result).to eq true
      end
    end

    context "given a .js file" do
      it "returns true" do
        result = Linter::Eslint.can_lint?("foo.js")

        expect(result).to eq true
      end
    end

    context "given a .jsx file" do
      it "returns true" do
        result = Linter::Eslint.can_lint?("foo.jsx")

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
        linter_name: "eslint",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "{}",
      )
    end
  end

  describe "#file_included?" do
    context "file is in excluded file list" do
      it "returns false" do
        stub_eslint_config
        linter = build_linter(nil, Linter::Eslint::IGNORE_FILENAME => "foo.js")
        commit_file = double("CommitFile", filename: "foo.js")

        expect(linter.file_included?(commit_file)).to eq false
      end
    end

    context "file is not excluded" do
      it "returns true" do
        stub_eslint_config
        linter = build_linter(nil, Linter::Eslint::IGNORE_FILENAME => "foo.js")
        commit_file = double("CommitFile", filename: "bar.js")

        expect(linter.file_included?(commit_file)).to eq true
      end

      it "matches a glob pattern" do
        stub_eslint_config
        linter = build_linter(
          nil,
          Linter::Eslint::IGNORE_FILENAME => "app/javascripts/*.js\nvendor/*",
        )
        commit_file1 = double(
          "CommitFile",
          filename: "app/javascripts/bar.js",
        )
        commit_file2 = double(
          "CommitFile",
          filename: "vendor/javascripts/foo.js",
        )

        expect(linter.file_included?(commit_file1)).to be false
        expect(linter.file_included?(commit_file2)).to be false
      end
    end
  end

  def stub_eslint_config(content: {}, excluded_paths: [])
    stubbed_eslint_config = double(
      "EslintConfig",
      content: content,
      excluded_paths: excluded_paths,
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
