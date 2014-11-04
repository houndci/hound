require "fast_spec_helper"
require "app/models/violation"
require "app/models/style_guide/base"
require "app/models/style_guide/scss"

describe StyleGuide::Scss do
  describe "#violations_in_file" do
    context "with default configuration" do
      describe "for single quotes" do
        it "has one violation" do
          content = <<-CODE
.a { display: 'none'; }
          CODE

          expect(violations_in(content)).to include(
            "Prefer double-quoted strings"
          )
        end
      end

      describe "for no leading zeros" do
        it "has one violation" do
          content = <<-CODE
.a { margin: .5em; }
          CODE

          expect(violations_in(content)).to include(
            "`.5` should be written with a leading zero as `0.5`"
          )
        end
      end
    end

    context "with custom configuration" do
      describe "for single quotes" do
        it "returns no violation" do
          config = {
            "linters" => {
              "StringQuotes" => {
                "style" => "single_quotes"
              }
            }
          }

          content = <<-CODE
.a { display: 'none'; }
          CODE

          expect(violations_in(content, config)).to eq []
        end
      end

      describe "for no leading zeros" do
        it "returns no violation" do
          config = {
            "linters" => {
              "LeadingZero" => {
                "style" => "exclude_zero"
              }
            }
          }

          content = <<-CODE
.a { margin: .5em; }
          CODE

          expect(violations_in(content, config)).to eq []
        end
      end
    end
  end

  private

  def violations_in(content, config = nil)
    repo_config = double("RepoConfig", enabled_for?: true, for: config)
    style_guide = StyleGuide::Scss.new(repo_config)
    style_guide.violations_in_file(build_file(content)).flat_map(&:messages)
  end

  def build_file(content)
    line = double("Line", content: "blah", number: 1, patch_position: 2)
    double("CommitFile", content: content, filename: "lib/a.scss", line_at: line)
  end
end
