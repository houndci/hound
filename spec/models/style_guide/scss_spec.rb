require "spec_helper"

describe StyleGuide::Scss do
  describe "#violations_in_file" do
    context "without config" do
      context "with single quotes" do
        it "does not return violations" do
          deep_nested_selectors = ".a { display: 'none'; }"

          expect(violations_in(deep_nested_selectors)).to be_empty
        end
      end
    end

    context "with single quote rule in config" do
      describe "with single quotes" do
        it "returns violations" do
          config_file = "scss_style.yml"
          deep_nested_selectors = ".a { display: 'none'; }"

          expect(violations_in(deep_nested_selectors, config_file)).not_to be_empty
        end
      end
    end
  end

  private

  def violations_in(content, config_file = nil)
    style_guide = if config_file
      config = File.read(File.join("spec/support/fixtures", config_file))
      StyleGuide::Scss.new(config)
    else
      StyleGuide::Scss.new
    end

    style_guide.violations_in_file(build_commit_file(content)).
      flat_map(&:messages)
  end

  def build_commit_file(content)
    line = double("Line", content: nil, number: 1, patch_position: 2)
    double("CommitFile", content: content, filename: "lib/a.scss", line_at: line)
  end
end
