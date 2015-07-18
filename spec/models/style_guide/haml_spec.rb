require "rails_helper"

describe StyleGuide::Haml do
  describe "#file_review" do
    it "returns complete file review" do
      style_guide = build_style_guide({})
      file = build_file("")

      expect(style_guide.file_review(file)).to be_completed
    end

    context "with default configuration" do
      context "with an implicit %div violation" do
        it "does not return violations" do
          content = "%div#container Hello"

          expect(violations_in(content)).to be_empty
        end
      end
    end

    context "with configuration including implicit div linter" do
      context "for implicit %div violation" do
        it "returns violations" do
          content = "%div#container Hello"
          config = {
            "linters" => {
              "ImplicitDiv" => {
                "enabled" => true
              }
            }
          }

          expect(violations_in(content, config)).to include(
            "`%div#container` can be written as `#container` since `%div` is " +
            "implicit"
          )
        end
      end
    end
  end

  private

  def violations_in(content, config = {})
    style_guide = build_style_guide(config)
    style_guide.file_review(build_file(content)).violations.
      flat_map(&:messages)
  end

  def build_style_guide(config)
    repo_config = double("RepoConfig", enabled_for?: true, for: config)
    repository_owner_name = "ralph"
    StyleGuide::Haml.new(repo_config, repository_owner_name)
  end

  def build_file(content)
    build_commit_file(filename: "a/b.haml", content: content)
  end
end
