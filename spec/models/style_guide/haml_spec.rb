require "spec_helper"

describe StyleGuide::Haml do
  describe "#violations_in_file" do
    context "with default configuration" do
      context "with an implicit %div violation" do
        it "returns violations" do
          content = "%div#container Hello"

          expect(violations_in(content)).to include(
            "`%div#container` can be written as `#container` since `%div` is " +
            "implicit"
          )
        end
      end
    end

    context "with configuration excluding implicit div linter" do
      context "for implicit %div violation" do
        it "returns violations" do
          content = "%div#container Hello"
          config = {
            "linters" => {
              "ImplicitDiv" => {
                "enabled" => false
              }
            }
          }

          expect(violations_in(content, config)).to be_empty
        end
      end
    end
  end

  private

  def violations_in(content, config = {})
    style_guide = build_style_guide(config)
    style_guide.violations_in_file(
      build_file(content)
    ).flat_map(&:messages)
  end

  def build_style_guide(config)
    repo_config = double("RepoConfig", enabled_for?: true, for: config)
    repository_owner_name = "ralph"
    StyleGuide::Haml.new(repo_config, repository_owner_name)
  end

  def build_file(text)
    line = double("Line", content: "blah", number: 1, patch_position: 2)
    double("CommitFile", content: text, filename: "a/b.haml", line_at: line)
  end
end
