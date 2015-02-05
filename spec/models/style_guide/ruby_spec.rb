require "spec_helper"

describe StyleGuide::Ruby, "#violations_in_file" do
  context "when code violates configured style" do
    context "with namespace" do
      it "returns violations" do
        config_file = "ruby_style_with_namespaces.yml"

        expect(violations_in(<<-CODE, config_file)).not_to be_empty
users.find do |user|
  user.active?
end
        CODE
      end
    end

    context "without namespace" do
      it "returns violations" do
        config_file = "ruby_style_without_namespaces.yml"

        expect(violations_in(<<-CODE, config_file)).not_to be_empty
users.find do |user|
  user.active?
end
        CODE
      end
    end

    context "with excluded files" do
      it "does not return violations" do
        config_file = "ruby_style_with_excluded_files.yml"

        violations = violations_in(<<-CODE, config_file)
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

  def violations_in(content, config_file = nil)
    style_guide = if config_file
      config = File.read(File.join("spec/support/fixtures", config_file))
      StyleGuide::Ruby.new(config)
    else
      StyleGuide::Ruby.new
    end

    style_guide.
      violations_in_file(build_commit_file(content)).
      flat_map(&:messages)
  end

  def build_commit_file(content)
    line = double("Line", content: nil, number: 1, patch_position: 2)
    double("CommitFile", content: content, filename: "lib/a.rb", line_at: line)
  end
end
