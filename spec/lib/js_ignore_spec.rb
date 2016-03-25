require "spec_helper"
require "lib/js_ignore"

describe JsIgnore do
  let(:jsignore) { JsIgnore.new({}, ".ignorethese") }

  describe "#file_included?" do
    context "file is in excluded file list" do
      it "returns false" do
        set_ignored_paths(["foo.js"])
        commit_file = double("CommitFile", filename: "foo.js")

        expect(jsignore.file_included?(commit_file)).to eq false
      end
    end

    context "file is not excluded" do
      it "returns true" do
        set_ignored_paths(["foo.js"])
        commit_file = double("CommitFile", filename: "bar.js")

        expect(jsignore.file_included?(commit_file)).to eq true
      end

      it "matches a glob pattern" do
        set_ignored_paths(["app/assets/javascripts/*.js", "vendor/*"])
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

    def set_ignored_paths(paths)
      allow(jsignore).to receive(:ignored_paths).and_return(paths)
    end
  end
end
