require "app/policies/commenting_policy"

RSpec.describe CommentingPolicy do
  describe "#comment_on?" do
    context "when line with violation has not been previously commented on" do
      it "returns true" do
        commenting_policy = CommentingPolicy.new([])

        result = commenting_policy.comment_on?(stub_violation)

        expect(result).to eq true
      end
    end

    context "when line with violation has been previously commented on" do
      context "when comment includes violation message" do
        it "returns false" do
          violation = stub_violation(
            filename: "foo.rb",
            messages: ["Trailing whitespace detected"],
          )
          comment = stub_comment(
            body: "Trailing whitespace detected<br>Extra newline",
            position: violation.patch_position,
            path: violation.filename,
          )
          commenting_policy = CommentingPolicy.new([comment])

          result = commenting_policy.comment_on?(stub_violation)

          expect(result).to eq false
        end
      end

      context "when comment exists for the same line but different files" do
        it "returns true" do
          violation = stub_violation(filename: "foo.rb", messages: ["foo bar"])
          comment = stub_comment(
            body: "foo bar",
            position: nil,
            oritinal_position: violation.patch_position,
            path: "bar.rb",
          )
          commenting_policy = CommentingPolicy.new([comment])

          result = commenting_policy.comment_on?(violation)

          expect(result).to eq true
        end
      end

      context "when comment does not include violation message" do
        it "returns true" do
          violation = stub_violation(messages: ["foo bar"])
          comment = stub_comment(
            body: "Extra newline",
            position: violation.patch_position,
            path: violation.filename,
          )
          commenting_policy = CommentingPolicy.new([comment])

          result = commenting_policy.comment_on?(violation)

          expect(result).to eq true
        end
      end

      context "when commented line changes patch location" do
        it "returns false" do
          violation = stub_violation(messages: ["Trailing whitespace detected"])
          comment = stub_comment(
            body: "Trailing whitespace detected<br>Extra newline",
            position: violation.patch_position,
            original_position: violation.patch_position + 3,
            path: violation.filename,
          )
          commenting_policy = CommentingPolicy.new([comment])

          result = commenting_policy.comment_on?(violation)

          expect(result).to eq false
        end
      end
    end
  end

  def stub_comment(options = {})
    defaults = { user: double("GitHubUser", login: "houndci-bot") }
    double("GitHubComment", defaults.merge(options))
  end

  def stub_violation(options = {})
    defaults = {
      filename: "foo.rb",
      messages: ["Extra newline"],
      patch_position: 1,
    }
    instance_double("Violation", defaults.merge(options))
  end
end
