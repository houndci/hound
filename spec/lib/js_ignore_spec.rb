require "spec_helper"
require "pathspec"
require "lib/js_ignore"

describe JsIgnore do
  describe "#file_included?" do
    let(:ignore_file_content) do
      <<~EOS
        foo/*
        !foo/lint-me.js
        bar
        /baz
        **/qux/*.js
      EOS
    end

    it "returns false for ignored files" do
      jsignore = build_js_ignore("jshint", ignore_file_content)

      expect(jsignore.file_included?("foo/file1.js")).to be false
      expect(jsignore.file_included?("foo/lint-me.js")).to be true
      expect(jsignore.file_included?("bar/file2.js")).to be false
      expect(jsignore.file_included?("baz/file3.js")).to be false
      expect(jsignore.file_included?("abc/qux/def.js")).to be false
      expect(jsignore.file_included?("vendor/file4.js")).to be false
      expect(jsignore.file_included?("node_modules/blah/file5.js")).to be false
    end

    it "returns true for non-ignored files" do
      jsignore = build_js_ignore("jshint", ignore_file_content)

      expect(jsignore.file_included?("foo/lint-me.js")).to be true
      expect(jsignore.file_included?("should/lint.js")).to be true
      expect(jsignore.file_included?("should-lint.js")).to be true
      expect(jsignore.file_included?("bar.js")).to be true
    end
  end

  def build_js_ignore(linter, content)
    hound_config = build_hound_config(linter, ".custom_js_ignore", content)

    JsIgnore.new(linter, hound_config, ".jsignore")
  end

  def build_hound_config(linter, ignore_filename, content)
    config_content = {
      linter => {
        "ignore_file" => ignore_filename,
      },
    }
    commit = stub_commit(
      ".hound.yml" => "#{linter}:\n  ignore_file: #{ignore_filename}",
      ignore_filename => content,
    )

    instance_double("HoundConfig", content: config_content, commit: commit)
  end
end
