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

    context "given a non-js file" do
      it "returns false" do
        result = Linter::JavaScript.can_lint?("foo.js.coffee")

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
        it "returns a collection of violation objects" do
          commit_file = build_js_file("var foo = 'bar'")

          violations = violations_in(commit_file: commit_file)

          violation = violations.first
          expect(violation.filename).to eq commit_file.filename
          expect(violation.line_number).to eq 1
          expect(violation.messages).to match_array([
            "Missing semicolon.",
            "'foo' is defined but never used.",
          ])
        end
      end
    end

    context "when semicolon check is disabled in config" do
      context "when semicolon is missing" do
        it "returns no violation" do
          commit_file = build_js_file("parseFloat('1')")
          config = stub_javascript_config(content: { "asi" => true })

          violations = violations_in(
            commit_file: commit_file,
            config: config,
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

    context "when a global variable is ignored" do
      it "returns no violations" do
        config = stub_javascript_config(content: { "predef" => ["myGlobal"] })
        commit_file = build_js_file("$(myGlobal).hide();")

        violations = violations_in(
          commit_file: commit_file,
          config: config,
        )

        expect(violations).to be_empty
      end
    end

    context "non-thoughtbot pull request" do
      it "uses the default hound configuration" do
        spy_on_file_read
        spy_on_jshintrb
        configuration_file_path = default_configuration_file(
          Linter::JavaScript,
        )
        commit_file = build_js_file("$(myGlobal).hide();")

        violations_in(
          commit_file: commit_file,
          repository_owner_name: "not_thoughtbot"
        )

        expect(File).to have_received(:read).with(configuration_file_path)
        expect(Jshintrb).to have_received(:lint).
          with(anything, default_configuration)
      end
    end

    context "thoughtbot pull request" do
      it "uses the thoughtbot hound configuration" do
        spy_on_file_read
        spy_on_jshintrb
        commit_file = build_js_file("$(myGlobal).hide();")
        configuration_file_path = thoughtbot_configuration_file(
          Linter::JavaScript,
        )

        violations_in(
          commit_file: commit_file,
          repository_owner_name: "thoughtbot",
        )

        expect(File).to have_received(:read).with(configuration_file_path)
        expect(Jshintrb).to have_received(:lint).
          with(anything, thoughtbot_configuration)
      end
    end

    context "with ES6 support enabled" do
      it "respects ES6" do
        config = stub_javascript_config(content: { "esnext" => true })
        commit_file = build_js_file("import Ember from 'ember'")

        violations = violations_in(
          commit_file: commit_file,
          config: config,
        )

        violation = violations.first
        expect(violation.messages).to match_array([
          "Missing semicolon.",
          "'Ember' is defined but never used.",
        ])
      end
    end
  end

  describe "#file_included?" do
    context "file is in excluded file list" do
      it "returns false" do
        config = stub_javascript_config(excluded_files: ["foo.js"])
        linter = build_linter(config: config)
        commit_file = double("CommitFile", filename: "foo.js")

        expect(linter.file_included?(commit_file)).to eq false
      end
    end

    context "file is not excluded" do
      it "returns true" do
        config = stub_javascript_config(excluded_files: ["foo.js"])
        linter = build_linter(config: config)
        commit_file = double("CommitFile", filename: "bar.js")

        expect(linter.file_included?(commit_file)).to eq true
      end

      it "matches a glob pattern" do
        config = stub_javascript_config(
          excluded_files: [
            "app/assets/javascripts/*.js",
            "vendor/*",
          ],
        )
        linter = build_linter(config: config)
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

  def build_js_file(content = "foo")
    build_commit_file(filename: "some-file.js", content: content)
  end

  def violations_in(
    commit_file:,
    repository_owner_name: "foo",
    config: stub_javascript_config
  )
    linter = build_linter(
      config: config,
      repository_owner_name: repository_owner_name,
    )
    linter.file_review(commit_file).violations
  end

  def build_linter(
    hound_config: default_hound_config,
    repository_owner_name: "not_thoughtbot",
    config: stub_javascript_config
  )
    config
    Linter::JavaScript.new(
      hound_config: hound_config,
      build: build(:build),
      repository_owner_name: repository_owner_name,
    )
  end

  def stub_javascript_config(content: {}, excluded_files: [])
    config = double(
      "JavaScriptConfig",
      content: content,
      excluded_files: excluded_files,
    )
    allow(Config::JavaScript).to receive(:new).and_return(config)
    config
  end

  def default_hound_config
    double("HoundConfig", enabled_for?: true, content: {})
  end

  def default_configuration
    config_file_path = default_configuration_file(Linter::JavaScript)
    config_file = File.read(config_file_path)
    JSON.parse(config_file)
  end

  def thoughtbot_configuration
    config_file_path = thoughtbot_configuration_file(Linter::JavaScript)
    config_file = File.read(config_file_path)
    JSON.parse(config_file)
  end

  def spy_on_jshintrb
    allow(Jshintrb).to receive(:lint).and_return([])
  end
end
