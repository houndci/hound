require "fast_spec_helper"
require "coffeelint"
require "active_support/core_ext/string/strip"
require "app/models/style_guide/coffee_script"
require "app/models/violation"

describe StyleGuide::CoffeeScript do
  describe "#violations" do
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

    context "with violation on line that was not modified" do
      it "finds no violations" do
        file = double(
          :file,
          content: "'hello'",
          filename: "lib/test.coffee",
          modified_line_at: nil,
        )
        style_guide = StyleGuide::CoffeeScript.new

        violations = style_guide.violations(file)

        expect(violations).to eq []
      end
    end

    private

    def violations_in(content)
      unless content.end_with?("\n")
        content += "\n"
      end

      style_guide = StyleGuide::CoffeeScript.new
      style_guide.violations(build_file(content)).map(&:messages).flatten
    end

    def build_file(content)
      double(
        :file,
        content: content,
        filename: "test.coffee",
        modified_line_at: 1
      )
    end
  end
end
