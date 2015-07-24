require "rails_helper"

describe StyleGuide::Haml do
  let(:filename) { "app/views/show.html.haml" }

  describe "#file_review" do
    it "returns complete file review" do
      style_guide = build_style_guide({})
      file = build_file("")

      expect(style_guide.file_review(file)).to be_completed
    end

    context "with default configuration" do
      context "with an implicit %div violation" do
        it "does not return violations" do
          content = "%div#container Hello\n"

          expect(violations_in(content)).to be_empty
        end
      end
    end

    context "when linter excludes a file" do
      it "does not return violations" do
        config = {
          "linters" => {
            "ClassesBeforeIds" => {
              "enabled" => true,
              "exclude" => filename,
            }
          }
        }
        content = "%div#bar.foo\n"

        expect(violations_in(content, config)).to be_empty
      end
    end

    context "with violations in file" do
      it "returns violations" do
        content = <<-EOS.strip_heredoc
          .main
            %div#foo
              %span{class: "sky" } Hello
        EOS
        config = {
          "linters" => {
            "SpaceInsideHashAttributes" => {
              "enabled" => true,
              "style" => "no_space",
            },
            "ImplicitDiv" => {
              "enabled" => true,
            },
          },
        }

        expect(violations_in(content, config)).to match_array [
          "`%div#foo` can be written as `#foo` since `%div` is implicit",
          "Hash attribute should end with no space before the closing brace",
        ]
      end
    end
  end

  describe "#file_included?" do
    context "with excluded file" do
      it "returns false" do
        config = { "exclude" => filename }
        style_guide = build_style_guide(config)

        expect(style_guide.file_included?(filename)).to eq false
      end
    end

    context "with non-excluded file" do
      it "returns true" do
        config = { "exclude" => "app/views/clearance/**" }
        style_guide = build_style_guide(config)

        expect(style_guide.file_included?(filename)).to eq true
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
    build_commit_file(filename: filename, content: content)
  end
end
