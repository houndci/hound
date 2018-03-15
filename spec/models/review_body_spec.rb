# frozen_string_literal: true

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

        expect(result).to eq <<~EOS.chomp
          Some files could not be reviewed due to errors:
          <details>
          <summary>invalid config</summary>
          <pre>invalid config</pre>
          </details>
          <details>
          <summary>foo</summary>
          <pre>foo
            bar</pre>
          </details>
        EOS
      end

      context "when errors are too long" do
        it "truncates the errors" do
          stub_const("ReviewBody::HEADER", "errs")
          stub_const("ReviewBody::DETAILS_FORMAT", "%s:\n'%s'")
          stub_const("ReviewBody::SUMMARY_LENGTH", 5)
          stub_const("ReviewBody::MAX_BODY_LENGTH", 40)
          review_body = ReviewBody.new(
            [
              "err1\n  foo",
              "err2\n  bar\n  baz",
            ],
          )

          result = review_body.to_s

          expect(result.size).to eq 40
          expect(result).to eq <<~EOS.chomp
            errs
            err1:
            'err1
              foo'
            err2:
            'err2
              b'
          EOS
        end
      end
    end
  end
end
