require "spec_helper"
require "lib/js_ignore"

describe JsIgnore do
  describe "#file_included?" do
    context "file is in excluded file list" do
      it "returns false" do
        jsignore = build_js_ignore("javascript", "foo/*")
        commit_file = double("CommitFile", filename: "foo/bar.js")

        expect(jsignore.file_included?(commit_file)).to eq false
      end

      context "with a different linter" do
        it "returns false" do
          jsignore = build_js_ignore("eslint", "foo/*")
          commit_file = instance_double("CommitFile", filename: "foo/bar.js")

          expect(jsignore.file_included?(commit_file)).to be false
        end
      end
    end

    context "file is not excluded" do
      it "returns true" do
        jsignore = build_js_ignore("javascript", "foo/*")
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
        jsignore = build_js_ignore("javascript", ignore_file_content)

        expect(jsignore.file_included?(commit_file1)).to be false
        expect(jsignore.file_included?(commit_file2)).to be false
      end
    end

    def build_js_ignore(linter, content)
      hound_config = build_hound_config(linter, ".jsignore", content)

      JsIgnore.new("javascript", hound_config, ".jsignore")
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

      instance_double("HoundConfig", content: config_content, commit: commit)
    end
  end
end
