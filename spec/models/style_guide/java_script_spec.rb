require "fast_spec_helper"
require "jshintrb"
require "app/models/violation"
require "app/models/style_guide/base"
require "app/models/style_guide/java_script"

describe StyleGuide::JavaScript do
  describe "#violations_in_file" do
    context "with default config" do
      context "when semicolon is missing" do
        it "returns violation" do
          repo_config = double("RepoConfig", for: {})
          style_guide = StyleGuide::JavaScript.new(repo_config)
          file = double(:file, content: "var blahh = 'blahh'").as_null_object

          violations = style_guide.violations_in_file(file)

          expect(violations.first.messages).to include "Missing semicolon."
        end
      end
    end

    context "when semicolon check is disabled in config" do
      context "when semicolon is missing" do
        it "returns no violation" do
          repo_config = double("RepoConfig", for: { "asi" => true })
          style_guide = StyleGuide::JavaScript.new(repo_config)
          file = double(:file, content: "parseFloat('1')").as_null_object

          violations = style_guide.violations_in_file(file)

          expect(violations).to be_empty
        end
      end
    end

    context "when jshintrb returns nil violation" do
      it "returns no violations" do
        repo_config = double("RepoConfig", for: {})
        style_guide = StyleGuide::JavaScript.new(repo_config)
        file = double(:file).as_null_object
        allow(Jshintrb).to receive_messages(lint: [nil])

        violations = style_guide.violations_in_file(file)

        expect(violations).to be_empty
      end
    end

    context "when a global variable is ignored" do
      it "returns no violations" do
        repo_config = double("RepoConfig", for: { "predef" => ["myGlobal"] })
        style_guide = StyleGuide::JavaScript.new(repo_config)
        file = double(:file, content: "$(myGlobal).hide();").as_null_object

        violations = style_guide.violations_in_file(file)

        expect(violations).to be_empty
      end
    end
  end

  describe "#file_included?" do
    context "file is in excluded file list" do
      it "returns false" do
        repo_config = double("RepoConfig", ignored_javascript_files: ["foo.js"])
        style_guide = StyleGuide::JavaScript.new(repo_config)
        file = double(:file, filename: "foo.js")

        included = style_guide.file_included?(file)

        expect(included).to be false
      end
    end

    context "file is not excluded" do
      it "returns true" do
        repo_config = double("RepoConfig", ignored_javascript_files: ["foo.js"])
        style_guide = StyleGuide::JavaScript.new(repo_config)
        file = double(:file, filename: "bar.js")

        included = style_guide.file_included?(file)

        expect(included).to be true
      end
    end

    it "matches a glob pattern" do
      repo_config = double(
        "RepoConfig",
        ignored_javascript_files: ["app/assets/javascripts/*.js"]
      )

      style_guide = StyleGuide::JavaScript.new(repo_config)
      file = double(:file, filename: "app/assets/javascripts/bar.js")

      included = style_guide.file_included?(file)

      expect(included).to be false
    end
  end
end
