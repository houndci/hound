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

    context "over multiple runs" do
      it "it reports errors only for the given file" do
        style_guide = build_style_guide
        bad_content = ".a { .b { .c { background: #000; } } }"
        good_content = ".a { margin: 0.5em; }\n"

        bad_run = style_guide.violations_in_file(build_file(bad_content))
        good_run = style_guide.violations_in_file(build_file(good_content))

        expect(bad_run).not_to be_empty
        expect(good_run).to be_empty
      end
    end

    context "when a file is excluded" do
      context "when a file is inside an ignored directory" do
        it "returns no violations" do
          repo_config = double(
            "RepoConfig",
            enabled_for?: true,
            for: nil,
            ignored_paths: ["vendor/**"],
          )
          style_guide = build_style_guide
          allow(style_guide).to receive(:repo_config).and_return(repo_config)
          bad_content = ".a { .b { .c { background: #000; } } }"
          file = build_file(bad_content, filename: "vendor/foo.scss")

          expect(style_guide.violations_in_file(file)).to eq []
        end
      end

      context "when a file is ignored" do
        it "returns no violations" do
          style_guide = build_style_guide
          bad_content = ".a { .b { .c { background: #000; } } }"
          file = build_file(bad_content)
          config_double = double("SassConfig", excluded_file?: true)
          allow(style_guide).to receive(:config).and_return(config_double)

          expect(style_guide.violations_in_file(file)).to eq []
        end
      end
    end
  end

  private

  def violations_in(content, config = nil)
    style_guide = build_style_guide(config)
    style_guide.violations_in_file(build_file(content)).flat_map(&:messages)
  end

  def build_style_guide(config = nil)
    repo_config = double(
      "RepoConfig",
      enabled_for?: true,
      for: config,
      ignored_paths: [],
    )
    repository_owner_name = "ralph"
    StyleGuide::Scss.new(repo_config, repository_owner_name)
  end

  def build_file(text, filename: "lib/a.scss")
    line = double("Line", content: "blah", number: 1, patch_position: 2)
    double("CommitFile", content: text, filename: filename, line_at: line)
  end
end
