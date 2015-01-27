require "spec_helper"

describe StyleGuide::JavaScript do
  include ConfigurationHelper

  describe "#violations_in_file" do
    context "without config" do
      context "with trailing whitespace" do
        it "does not return violations" do
          expect(violations_in(<<-CODE)).to be_empty
var test = 'test';   
          CODE
        end
      end
    end

    context "with trailing whitespace rule in config" do
      context "with trailing whitespace" do
        it "returns violations" do
          config_file = "javascript_style.json"

          expect(violations_in(<<-CODE, config_file)).to_not be_empty
var test = 'test';   
          CODE
        end
      end
    end
  end

  # describe "#file_included?" do
  #   context "file is in excluded file list" do
  #     it "returns false" do
  #       repo_config = double("RepoConfig", ignored_javascript_files: ["foo.js"])
  #       style_guide = StyleGuide::JavaScript.new(repo_config, "ralph")
  #       file = double(:file, filename: "foo.js")

  #       included = style_guide.file_included?(file)

  #       expect(included).to be false
  #     end
  #   end

  #   context "file is not excluded" do
  #     it "returns true" do
  #       repo_config = double("RepoConfig", ignored_javascript_files: ["foo.js"])
  #       style_guide = StyleGuide::JavaScript.new(repo_config, "ralph")
  #       file = double(:file, filename: "bar.js")

  #       included = style_guide.file_included?(file)

  #       expect(included).to be true
  #     end
  #   end

  #   it "matches a glob pattern" do
  #     repo_config = double(
  #       "RepoConfig",
  #       ignored_javascript_files: ["app/assets/javascripts/*.js"]
  #     )

  #     style_guide = StyleGuide::JavaScript.new(repo_config, "ralph")
  #     file = double(:file, filename: "app/assets/javascripts/bar.js")

  #     included = style_guide.file_included?(file)

  #     expect(included).to be false
  #   end
  # end

  def violations_in(content, config_file = nil)
    if config_file
      stub_const(
        "StyleGuide::JavaScript::CUSTOM_CONFIG_FILE",
        File.join("spec/support/fixtures", config_file)
      )
    end

    style_guide = StyleGuide::JavaScript.new
    style_guide.violations_in_file(build_commit_file(content)).flat_map(&:messages)
  end

  def build_commit_file(content)
    line = double("Line", content: nil, number: 1, patch_position: 2)
    double("CommitFile", content: content, filename: "a.js", line_at: line)
  end
end
