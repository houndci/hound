require "rails_helper"

describe Linter::JavaScript do
  include ConfigurationHelper

  describe ".can_lint?" do
    context "given a .js file" do
      it "returns true" do
        result = Linter::JavaScript.can_lint?("foo.js")

        expect(result).to eq true
      end
    end

    context "given a .coffee.js file" do
      it "returns false" do
        result = Linter::JavaScript.can_lint?("foo.coffee.js")

        expect(result).to eq false
      end
    end

    context "given a non-js file" do
      it "returns false" do
        result = Linter::JavaScript.can_lint?("foo.rb")

        expect(result).to eq false
      end
    end
  end

  describe "#file_review" do
    it "returns a saved and completed file review" do
      linter = build_linter
      commit_file = build_js_file

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).to be_completed
    end

    context "with default config" do
      context "when semicolon is missing" do
        it "finds violations" do
          commit_file = build_js_file("var foo = 'bar'")

          violations = violations_in(commit_file: commit_file)

          violation = violations.first
          expect(violation.line_number).to eq 1
          expect(violation.messages).to include "Missing semicolon."
        end
      end
    end

    context "with custom config" do
      context "when semicolon rule is disabled" do
        it "returns no violation" do
          repo_config = double("RepoConfig", for: { "asi" => true })
          commit_file = build_js_file("parseFloat('1')")

          violations = violations_in(
            commit_file: commit_file,
            repo_config: repo_config
          )

          expect(violations).to be_empty
        end
      end
    end

    context "when jshintrb returns nil violation" do
      it "returns no violations" do
        commit_file = double("CommitFile").as_null_object
        allow(Jshintrb).to receive_messages(lint: [nil])

        violations = violations_in(commit_file: commit_file)

        expect(violations).to be_empty
      end
    end
  end

  describe "#file_included?" do
    context "file is in excluded file list" do
      it "returns false" do
        repo_config = double("RepoConfig", ignored_javascript_files: ["foo.js"])
        linter = build_linter(repo_config: repo_config)
        commit_file = double("CommitFile", filename: "foo.js")

        included = linter.file_included?(commit_file)

        expect(included).to be false
      end
    end

    context "file is not excluded" do
      it "returns true" do
        repo_config = double("RepoConfig", ignored_javascript_files: ["foo.js"])
        linter = build_linter(repo_config: repo_config)
        commit_file = double("CommitFile", filename: "bar.js")

        included = linter.file_included?(commit_file)

        expect(included).to be true
      end
    end

    it "matches a glob pattern" do
      repo_config = double(
        "RepoConfig",
        ignored_javascript_files: [
          "app/assets/javascripts/*.js",
          "vendor/*",
        ]
      )
      linter = build_linter(repo_config: repo_config)
      commit_file1 = double(
        "CommitFile",
        filename: "app/assets/javascripts/bar.js"
      )
      commit_file2 = double(
        "CommitFile",
        filename: "vendor/assets/javascripts/foo.js"
      )

      expect(linter.file_included?(commit_file1)).to be false
      expect(linter.file_included?(commit_file2)).to be false
    end
  end

  def build_js_file(content = "foo")
    build_commit_file(filename: "some-file.js", content: content)
  end

  def violations_in(
    commit_file:,
    repo_config: default_repo_config,
    repository_owner_name: "foo"
  )
    linter = build_linter(
      repo_config: repo_config,
      repository_owner_name: repository_owner_name,
    )
    linter.file_review(commit_file).violations
  end

  def build_linter(
    repo_config: default_repo_config,
    repository_owner_name: "not_thoughtbot"
  )
    Linter::JavaScript.new(
      repo_config: repo_config,
      build: build(:build),
      repository_owner_name: repository_owner_name,
    )
  end

  def default_repo_config
    double("RepoConfig", enabled_for?: true, for: {})
  end
end
