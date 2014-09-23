require "active_support/core_ext/string/strip"
require "active_support/inflector"
require "attr_extras"
require "coffeelint"
require "fast_spec_helper"

require "app/models/style_guide/base"
require "app/models/style_guide/coffee_script"
require "app/models/violation"

describe StyleGuide::CoffeeScript do
  describe "#violations_in_file" do
    context "with default configuration" do
      context "for long line" do
        it "returns violation" do
          expect(violations_in("1" * 81).first).to match(/exceeds maximum/)
        end
      end

      context "for trailing whitespace" do
        it "returns violation" do
          expect(violations_in("1   ").first).to match(/trailing whitespace/)
        end
      end

      context "for inconsistent indentation" do
        it "returns violation" do
          code = <<-CODE.strip_heredoc
            class FooBar
              foo: ->
                  "bar"
          CODE

          expect(violations_in(code)).to be_any { |m| m =~ /inconsistent/ }
        end
      end

      context "for non-PascalCase classes" do
        it "returns violation" do
          result = violations_in("class strange_ClassNAME")

          expect(result).to be_any { |m| m =~ /camel cased/ }
        end
      end
    end

    context "with violation on unchanged line" do
      it "finds no violations" do
        file = double(
          :file,
          content: "'hello'",
          filename: "lib/test.coffee",
          line_at: nil,
        )
        repo_config = double("RepoConfig", enabled_for?: true, for: {})
        style_guide = StyleGuide::CoffeeScript.new(repo_config)

        violations = style_guide.violations_in_file(file)

        expect(violations.count).to eq 0
      end
    end

    private

    def violations_in(content)
      repo_config = double("RepoConfig", enabled_for?: true, for: {})
      style_guide = StyleGuide::CoffeeScript.new(repo_config)
      style_guide.violations_in_file(build_file(content)).flat_map(&:messages)
    end

    def build_file(content)
      line = double("Line", content: "blah", number: 1, patch_position: 2)
      double(:file, content: content, filename: "test.coffee", line_at: line)
    end
  end
end
