require "app/models/review_body"

RSpec.describe ReviewBody do
  describe "#to_s" do
    context "when no errors are passed" do
      it "returns empty string" do
        review_body = ReviewBody.new([])

        result = review_body.to_s

        expect(result).to eq ""
      end
    end

    context "with errors" do
      it "returns formatted errors" do
        review_body = ReviewBody.new(["invalid config", "foo\n  bar"])

        result = review_body.to_s

        expect(result).to eq(
          "Some files could not be reviewed due to errors:" \
            "<details><summary>invalid config</summary>" \
            "<pre>invalid config</pre></details>" \
            "<details><summary>foo</summary>" \
            "<pre>foo<br>  bar</pre></details>",
        )
      end

      context "when errors are too long" do
        it "truncates the errors" do
          stub_const("ReviewBody::MAX_BODY_LENGTH", 200)
          review_body = ReviewBody.new(
            [
              "invalid config",
              "rule is unknown\n  MyRule",
            ],
          )

          result = review_body.to_s

          expect(result).to eq(
            "Some files could not be reviewed due to errors:" \
              "<details><summary>invalid config</summary>" \
              "<pre>invalid</pre></details>" \
              "<details><summary>rule is unknown</summary>" \
              "<pre>rule i</pre></details>",
          )
        end
      end
    end
  end
end
