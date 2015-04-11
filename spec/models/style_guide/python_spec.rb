require "rails_helper"

describe StyleGuide::Python, "#violations_in_file" do
  include ConfigurationHelper

  context "with default configuration" do
    describe "for valid line" do
      it "returns no violations" do
        expect(violations_in("print('pep8')")).to eq []
      end
    end

    describe "for unused import" do
      it "returns violations" do
        violations = ["F401 'this' imported but unused"]
        expect(violations_in('import this')).to eq violations
      end
    end
  end

  private

  def violations_in(content, repository_owner_name: "ralph")
    repo_config = double("RepoConfig", enabled_for?: true, for: {})
    style_guide = StyleGuide::Python.new(
      repo_config,
      repository_owner_name
    )
    style_guide.violations_in_file(build_file(content)).flat_map(&:messages)
  end

  def build_file(content)
    line = double("Line", content: "blah", number: 1, patch_position: 2)
    double(:file, content: content, filename: "test.py", line_at: line)
  end
end
