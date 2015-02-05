require "spec_helper"

describe StyleGuide::CoffeeScript do
  describe "#violations_in_file" do
    context "without config" do
      context "for long line" do
        it "does not return violations" do
          long_line = "1" * 81

          expect(violations_in(long_line)).to be_empty
        end
      end
    end

    context "with long line rule in config" do
      context "with long line" do
        it "returns violations" do
          config_file = "coffeescript_style.json"
          long_line = "1" * 81

          expect(violations_in(long_line, config_file)).not_to be_empty
        end
      end
    end
  end

  def violations_in(content, config_file = nil)
    style_guide = if config_file
      config = File.read(File.join("spec/support/fixtures", config_file))
      StyleGuide::CoffeeScript.new(config)
    else
      StyleGuide::CoffeeScript.new
    end

    style_guide.violations_in_file(build_commit_file(content)).
      flat_map(&:messages)
  end

  def build_commit_file(content)
    line = double("Line", content: nil, number: 1, patch_position: 2)
    double("CommitFile", content: content, filename: "test.coffee", line_at: line)
  end
end
