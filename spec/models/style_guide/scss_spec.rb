require "active_support/core_ext/string/strip"
require "active_support/inflector"
require "attr_extras"
require "scss_lint"
require "sentry-raven"

require "fast_spec_helper"
require "app/models/style_guide/base"
require "app/models/style_guide/scss"
require "app/models/violation"

describe StyleGuide::Scss do
  describe "#violations_in_file" do
    context "with default configuration" do
      describe "when bad nested rules" do
        it "returns violation" do
          expect(violations_in(<<-CODE)).to include "Selector should have depth of applicability no greater than 3, but was 4"
            .table p.inner table td { background: red; }
          CODE
        end
      end
    end

    context "when bad nested rules check is disabled in config" do
      context "when bad nested rules" do
        it "returns no violation" do
          expect(violations_in(<<-CODE)).to eq []
            .table p.inner table td { background: red; }
          CODE
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
