require "spec_helper"
require "app/services/suggest_changes"
require "app/policies/commenting_policy"

RSpec.describe SuggestChanges do
  describe ".call" do
    it "makes suggestion for missing semicolon" do
      violation = instance_double(
        "Violation",
        messages: [
          "Missing semicolon semi",
          "Something else",
        ],
        source: "console.log('wat')"
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
end
