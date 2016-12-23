require "app/models/js_ignore"
require "app/models/hound_config"
require "app/models/config/parser"
require "app/services/resolve_config_aliases"
require "app/services/resolve_config_conflicts"
require "app/services/normalize_config"

describe JsIgnore do
  include CommitHelper

  describe "#file_included?" do
    context "file is in excluded file list" do
      it "returns false" do
        jsignore = build_js_ignore("jshint", "foo/*")
        commit_file = double("CommitFile", filename: "foo/bar.js")

        expect(jsignore.file_included?(commit_file)).to eq false
      end

      context "with a different linter" do
        it "returns false" do
          stubbed_commit = stub_commit(
            ".hound.yml" => <<~EOF,
                javascript:
                  ignore_file: .custom_js_ignore
            EOF
            ".custom_js_ignore" => "foo/*",
            ".jsignore" => "",
          )
          hound_config = HoundConfig.new(stubbed_commit)
          jsignore = JsIgnore.new("jshint", hound_config, ".jsignore")
          commit_file = instance_double("CommitFile", filename: "foo/bar.js")

          expect(jsignore.file_included?(commit_file)).to be false
        end
      end
    end

    context "file is not excluded" do
      it "returns true" do
        jsignore = build_js_ignore("jshint", "foo/*")
        commit_file = double("CommitFile", filename: "foo.js")

        expect(jsignore.file_included?(commit_file)).to eq true
      end

      it "matches a glob pattern" do
        commit_file1 = double(
          "CommitFile",
          filename: "app/assets/javascripts/bar.js",
        )
        commit_file2 = double(
          "CommitFile",
          filename: "vendor/assets/javascripts/foo.js",
        )
        ignore_file_content = <<~TEXT
          app/assets/javascripts/*.js\n
          vendor/*
        TEXT
        jsignore = build_js_ignore("jshint", ignore_file_content)

        expect(jsignore.file_included?(commit_file1)).to be false
        expect(jsignore.file_included?(commit_file2)).to be false
      end
    end

    def build_js_ignore(linter, content)
      hound_config = build_hound_config(linter, ".custom_js_ignore", content)

      JsIgnore.new("jshint", hound_config, ".jsignore")
    end

    def build_hound_config(linter, ignore_filename, content)
      config_content = {
        linter => {
          "ignore_file" => ignore_filename,
        },
      }
      commit = instance_double("Commit")
      allow(commit).to receive(:file_content).with(ignore_filename).
        and_return(content)
      allow(commit).to receive(:file_content).with(".jsignore").and_return("")

      instance_double("HoundConfig", content: config_content, commit: commit)
    end
  end
end
