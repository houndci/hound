require "spec_helper"
require "app/services/suggest_changes"
require "app/policies/commenting_policy"

RSpec.describe SuggestChanges do
  describe ".call" do
    context "single violation" do
      it "makes a suggestion for a missing comma" do
        violation = instance_double(
          "Violation",
          messages: [
            "Put a comma after the last parameter of a multiline method call."
          ],
          source: "    violation.fetch(:source)"
        )
        suggest_changes = described_class.new(violation)

        result = suggest_changes.call

        expect(result).to eq <<~COMMENT.chomp
          Put a comma after the last parameter of a multiline method call.<br>```suggestion
              violation.fetch(:source),
          ```
        COMMENT
      end

      it "makes suggestion for missing semicolon" do
        violation = instance_double(
          "Violation",
          messages: [
            "Missing semicolon semi",
            "Something else",
          ],
          source: "  console.log('wat')"
        )
        suggest_changes = described_class.new(violation)

        result = suggest_changes.call

        expect(result).to eq <<~COMMENT.chomp
          Missing semicolon semi<br>Something else<br>```suggestion
            console.log('wat');
          ```
        COMMENT
      end

      it "makes suggestion for missing space after comma" do
        violation = instance_double(
          "Violation",
          messages: [
            "A space is required after ',' comma-spacing"
          ],
          source: "function wat(one,two, three) {"
        )
        suggest_changes = described_class.new(violation)

        result = suggest_changes.call

        expect(result).to eq <<~COMMENT.chomp
          A space is required after ',' comma-spacing<br>```suggestion
          function wat(one, two, three) {
          ```
        COMMENT
      end
    end

    context "multiple violations" do
      it "makes a suggestion for the first fixable violation" do
        violation = instance_double(
          "Violation",
          messages: [
            "Layout/TrailingWhitespace: Trailing whitespace detected.",
            "Put a comma after the last parameter of a multiline method call.",
          ],
          source: "    violation.fetch(:source) "
        )
        suggest_changes = described_class.new(violation)

        result = suggest_changes.call

        expect(result).to eq <<~COMMENT.chomp
          Layout/TrailingWhitespace: Trailing whitespace detected.<br>Put a comma after the last parameter of a multiline method call.<br>```suggestion
              violation.fetch(:source)
          ```
        COMMENT
      end
    end
  end
end
