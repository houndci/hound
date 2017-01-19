require "app/models/config/json_with_comments"

describe Config::JsonWithComments do
  describe "#without_comments" do
    context "with mixed comments" do
      it "returns raw JSON content without comments" do
        config = <<~TEXT
          /* start
            of
            file */
          {
            "foo": 1, // comments here
            "bar": 2,
            "baz": "// hello", // more comments
          }
          /* end of file */
        TEXT

        result = described_class.new(config).without_comments

        expect(result).to eq <<~TEXT
          {
            "foo": 1,
            "bar": 2,
            "baz": "// hello",
          }
        TEXT
      end
    end

    context "with single line comments" do
      it "returns raw JSON content without comments" do
        config = <<~TEXT
          {
            "foo": 1, // comments here
            "bar": 2,
          }
        TEXT

        result = described_class.new(config).without_comments

        expect(result).to eq <<~TEXT
          {
            "foo": 1,
            "bar": 2,
          }
        TEXT
      end
    end
  end
end
