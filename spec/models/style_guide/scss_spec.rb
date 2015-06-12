require "rails_helper"

describe StyleGuide::Scss do
  describe "#file_review" do
    it "returns a completed file review" do
      file = build_file("foo")

      result = build_style_guide.file_review(file)

      expect(result).to be_completed
    end

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
      context "for single quotes" do
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

      context "for no leading zeros" do
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

      context "when exclude is provided as string" do
        it "does not error" do
          pending

          content = ".a { margin: .5em; }\n"
          config = {
            "linters" => {
              "LeadingZero" => {
                "exclude" => "lib/**",
              }
            }
          }

          expect(violations_in(content, config)).to be_empty
        end
      end
    end

    context "over multiple runs" do
      it "it reports errors only for the given file" do
        bad_content = ".a { .b { .c { background: #000; } } }"
        good_content = ".a { margin: 0.5em; }\n"

        bad_run = violations_in(bad_content)
        good_run = violations_in(good_content)

        expect(bad_run).not_to be_empty
        expect(good_run).to be_empty
      end
    end
  end

  describe "#file_included?" do
    context "when file is excluded" do
      it "returns false" do
        pending

        config = {
          "exclude" => "lib/**"
        }
        repo_config = double("RepoConfig", for: config)
        style_guide = StyleGuide::Scss.new(repo_config, "ralph")
        file = double("CommitFile", filename: "lib/exclude.scss")

        expect(style_guide.file_included?(file)).to eq false
      end
    end

    context "when file is included" do
      it "returns true" do
        config = {}
        repo_config = double("RepoConfig", for: config)
        style_guide = StyleGuide::Scss.new(repo_config, "ralph")
        file = double("CommitFile", filename: "application.scss")

        expect(style_guide.file_included?(file)).to eq true
      end
    end
  end

  private

  def violations_in(content, config = nil)
    style_guide = build_style_guide(config)
    style_guide.file_review(build_file(content)).violations.
      flat_map(&:messages)
  end

  def build_style_guide(config = nil)
    repo_config = double("RepoConfig", enabled_for?: true, for: config)
    repository_owner_name = "ralph"
    StyleGuide::Scss.new(repo_config, repository_owner_name)
  end

  def build_file(text)
    line = double(
      "Line",
      changed?: true,
      content: "blah",
      number: 1,
      patch_position: 2
    )
    double("CommitFile", content: text, filename: "lib/a.scss", line_at: line)
  end
end
