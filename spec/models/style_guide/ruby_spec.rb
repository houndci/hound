require "spec_helper"

describe StyleGuide::Ruby, "#violations_in_file" do
  context "when code violates configured style" do
    context "with namespace" do
      it "returns violations" do
        config = {
          "Style/CollectionMethods" => {
            "Enabled" => true,
            "PreferredMethods" => {
              "find" => "detect"
            }
          }
        }

        expect(violations_in(<<-CODE, config: config)).not_to be_empty
users.find do |user|
  user.active?
end
        CODE
      end
    end

    context "without namespace" do
      it "returns violations" do
        config = {
          "CollectionMethods" => {
            "Enabled" => true,
            "PreferredMethods" => {
              "find" => "detect"
            }
          }
        }

        expect(violations_in(<<-CODE, config: config)).not_to be_empty
users.find do |user|
  user.active?
end
        CODE
      end
    end

    context "when configured to show cop names" do
      it "returns violations including cop names" do
        config = {
          "ShowCopNames" => true,
          "CollectionMethods" => {
            "Enabled" => true,
            "PreferredMethods" => {
              "find" => "detect"
            }
          }
        }

        violations = violations_in(<<-CODE, config: config)
users.find do |user|
  user.active?
end
        CODE

        expect(violations.size).to eq 1
        expect(violations.first).to include "CollectionMethods"
      end
    end

    context "with excluded files" do
      it "does not return violations" do
        config = {
          "AllCops" => {
            "Exclude" => ["lib/a.rb"]
          },
          "CollectionMethods" => {
            "Enabled" => true,
            "PreferredMethods" => {
              "find" => "detect"
            }
          }
        }

        violations = violations_in(<<-CODE, config: config)
users.find do |user|
  user.active?
end
        CODE

        expect(violations).to be_empty
      end
    end
  end

  context "when code violates default RuboCop style" do
    it "does not return violations" do
      expect(violations_in(<<-CODE)).to be_empty
def foo
  "foo"
end

alias :baz :foo
      CODE
    end
  end

  private

  def violations_in(content, config: nil)
    repo_config = double("RepoConfig", enabled_for?: true, for: config)
    style_guide = StyleGuide::Ruby.new(repo_config, "ralph")
    style_guide.violations_in_file(build_file(content)).flat_map(&:messages)
  end

  def build_file(content)
    line = double("Line", content: "blah", number: 1, patch_position: 2)
    double("CommitFile", content: content, filename: "lib/a.rb", line_at: line)
  end
end
