require "spec_helper"
require "app/services/suggest_changes"
require "app/policies/commenting_policy"

RSpec.describe SuggestChanges do
  describe ".call" do
    it "returns comment with suggested changes" do
      violation = instance_double(
        "Violation",
        messages: [
          "Missing semicolon semi"
        ],
        source: "console.log('wat')"
      )
      suggest_changes = described_class.new(violation)

      result = suggest_changes.call

      expect(result).to eq <<~COMMENT.chomp
        Missing semicolon semi
        <br>
        ```suggestion
        console.log('wat');
        ```
      COMMENT
    end
  end
end
