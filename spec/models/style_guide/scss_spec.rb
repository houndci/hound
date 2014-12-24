require "spec_helper"

describe StyleGuide::Scss do
  describe "#violations_in_file" do
    context "with default configuration" do
      describe "for deep nested selectors" do
        it "returns violation" do
          content = ".a { .b { .c { background: #000; } } }"

          expect(violations_in(content)).to include(
            "Selector should have depth of applicability no greater than 2, but was 3"
          )
        end
      end

      describe "for single quotes" do
        it "has one violation" do
          content = ".a { display: 'none'; }"

          expect(violations_in(content)).to include(
            "Prefer double-quoted strings"
          )
        end
      end

      describe "for no leading zeros" do
        it "has one violation" do
          content = ".a { margin: .5em; }"

          expect(violations_in(content)).to include(
            "`.5` should be written with a leading zero as `0.5`"
          )
        end
      end
    end

    context "with custom configuration" do
      describe "for single quotes" do
        it "returns no violation" do
          content = ".a { display: 'none'; }\n"
          config = {
            "linters" => {
              "StringQuotes" => {
                "style" => "single_quotes"
              }
            }
          }

          expect(violations_in(content, config)).to eq []
        end
      end

      describe "for no leading zeros" do
        it "returns no violation" do
          content = ".a { margin: .5em; }\n"
          config = {
            "linters" => {
              "LeadingZero" => {
                "style" => "exclude_zero"
              }
            }
          }

          expect(violations_in(content, config)).to eq []
        end
      end
    end
  end

  private

  def violations_in(content, config = nil)
    repo_config = double("RepoConfig", enabled_for?: true, for: config)
    repository_owner = "ralph"
    style_guide = StyleGuide::Scss.new(repo_config, repository_owner)
    style_guide.violations_in_file(build_file(content)).flat_map(&:messages)
  end

  def build_file(text)
    line = double("Line", content: "blah", number: 1, patch_position: 2)
    double("CommitFile", content: text, filename: "lib/a.scss", line_at: line)
  end
end
