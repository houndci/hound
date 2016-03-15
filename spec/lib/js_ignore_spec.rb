require "spec_helper"
require "lib/js_ignore"

describe JsIgnore do
  describe "#file_included?" do
    context "file is in excluded file list" do
      it "returns false" do
        jsignore = build_js_ignore(["foo.js"])
        commit_file = double("CommitFile", filename: "foo.js")

        expect(jsignore.file_included?(commit_file)).to eq false
      end
    end

    context "file is not excluded" do
      it "returns true" do
        jsignore = build_js_ignore(["foo.js"])
        commit_file = double("CommitFile", filename: "bar.js")

        expect(jsignore.file_included?(commit_file)).to eq true
      end

      it "matches a glob pattern" do
        jsignore = build_js_ignore(["app/assets/javascripts/*.js", "vendor/*"])
        commit_file1 = double(
          "CommitFile",
          filename: "app/assets/javascripts/bar.js",
        )
        commit_file2 = double(
          "CommitFile",
          filename: "vendor/assets/javascripts/foo.js",
        )

        expect(jsignore.file_included?(commit_file1)).to be false
        expect(jsignore.file_included?(commit_file2)).to be false
      end
    end

    def build_js_ignore(paths)
      jsignore = JsIgnore.new({}, ".jsignore")
      allow(jsignore).to receive(:ignored_paths).and_return(paths)

      jsignore
    end
  end
end
