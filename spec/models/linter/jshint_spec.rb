require "rails_helper"

describe Linter::Jshint do
  describe ".can_lint?" do
    context "given a .js file" do
      it "returns true" do
        result = Linter::Jshint.can_lint?("foo.js")

        expect(result).to eq true
      end
    end

    context "given a .js.coffee file" do
      it "returns false" do
        result = Linter::Jshint.can_lint?("foo.js.coffee")

        expect(result).to eq false
      end
    end

    context "given a non-js file" do
      it "returns false" do
        result = Linter::Jshint.can_lint?("foo.rb")

        expect(result).to eq false
      end
    end
  end

  describe "#file_included?" do
    context "file is in excluded file list" do
      it "returns false" do
        stub_jshint_config(excluded_files: ["foo.js"])
        linter = build_linter
        commit_file = double("CommitFile", filename: "foo.js")

        expect(linter.file_included?(commit_file)).to eq false
      end
    end

    context "file is not excluded" do
      it "returns true" do
        stub_jshint_config(excluded_files: ["foo.js"])
        linter = build_linter
        commit_file = double("CommitFile", filename: "bar.js")

        expect(linter.file_included?(commit_file)).to eq true
      end

      it "matches a glob pattern" do
        stub_jshint_config(
          excluded_files: ["app/assets/javascripts/*.js", "vendor/*"],
        )
        linter = build_linter
        commit_file1 = double(
          "CommitFile",
          filename: "app/assets/javascripts/bar.js",
        )
        commit_file2 = double(
          "CommitFile",
          filename: "vendor/assets/javascripts/foo.js",
        )

        expect(linter.file_included?(commit_file1)).to be false
        expect(linter.file_included?(commit_file2)).to be false
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
      stub_jshint_config(content: {})
      commit_file = build_commit_file(filename: "lib/a.js")
      allow(Resque).to receive(:enqueue)
      linter = build_linter(build)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        JshintReviewJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "{}",
      )
    end
  end

  def stub_jshint_config(options = {})
    default_options = {
      content: {},
      excluded_files: [],
      serialize: "{}",
    }
    stubbed_jshint_config = double(
      "JshintConfig",
      default_options.merge(options),
    )
    allow(Config::Jshint).to receive(:new).and_return(stubbed_jshint_config)

    stubbed_jshint_config
  end

  def raw_hound_config
    <<-EOS.strip_heredoc
      jshint:
        enabled: true
        config_file: config/.jshintrc
    EOS
  end
end
