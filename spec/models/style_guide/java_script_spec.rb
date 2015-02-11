require "spec_helper"

describe StyleGuide::JavaScript do
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

    context "with excluded files" do
      it "does not return violations" do
        config_file = "javascript_style_with_excluded_files.json"

        expect(violations_in(<<-CODE, config_file)).to be_empty
var test = 'test';   
        CODE
      end
    end
  end

  def violations_in(content, config_file = nil)
    style_guide = if config_file
      config = File.read(File.join("spec/support/fixtures", config_file))
      StyleGuide::JavaScript.new(config)
    else
      StyleGuide::JavaScript.new
    end

    style_guide.violations_in_file(build_commit_file(content)).
      flat_map(&:messages)
  end

  def build_commit_file(content)
    line = double("Line", content: nil, number: 1, patch_position: 2)
    double("CommitFile", content: content, filename: "a.js", line_at: line)
  end
end
