require "spec_helper"

describe StyleGuide::Go do
  describe "#violations_in_file" do
    context "with style violations" do
      it "returns violation" do
        violations = ["expected 'package', found 'var'"]

        expect(violations_in(<<-CODE)).to eq violations
          var foo_bar string
        CODE
      end
    end

    context "without style violations" do
      it "does not return violation" do
        expect(violations_in(<<-CODE)).to be_empty
          package main
          var fooBar string
        CODE
      end
    end
  end

  def violations_in(content)
    repo_config = double("RepoConfig", enabled_for?: true, for: nil)
    style_guide = StyleGuide::Go.new(repo_config, "ownername")
    style_guide.violations_in_file(build_file(content)).flat_map(&:messages)
  end

  def build_file(content)
    line = double("Line", content: "doesntmatter", number: 1, patch_position: 2)
    filename = Rails.root.join("test.go")
    double("CommitFile", content: content, line_at: line, filename: filename)
  end
end
