require "fast_spec_helper"
require "coffeelint"
require "active_support/core_ext/string/strip"
require "app/models/style_guide/coffee_script"
require "app/models/violation"

describe StyleGuide::CoffeeScript, "#violations" do
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
        expect(violations_in(<<-CODE)).to be_any { |m| m =~ /inconsistent/ }
class FooBar
 foo: ->
   "bar"
        CODE
      end
    end

    context "for non-PascalCase classes" do
      it "returns violation" do
        result = violations_in("class strange_ClassNAME")

        expect(result).to be_any { |m| m =~ /camel cased/ }
      end
    end
  end

  context "with custom configuration" do
    it "finds no violations" do
      content = "1" * 110
      file = double(:file, content: content, filename: "test.coffee")
      config = <<-TEXT.strip_heredoc
        {
          "max_line_length": {
            "value": 120,
            "level": "error",
            "limitComments": true
          }
        }
      TEXT
      pull_request = double(:pull_request, config_for: config)
      style_guide = StyleGuide::CoffeeScript.new(pull_request)

      violations = style_guide.violations(file)

      expect(violations.map(&:messages).flatten).to be_empty
    end
  end

  private

  def violations_in(content)
    unless content.end_with?("\n")
      content += "\n"
    end
    pull_request = double(:pull_request, config_for: "{}")

    style_guide = StyleGuide::CoffeeScript.new(pull_request)
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
