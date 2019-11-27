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

  describe "#outdated_comments" do
    it "returns comments that no longer match any violations" do
      violation1 = stub_violation(
        messages: ["Missing newline"],
        patch_position: 2,
      )
      violation2 = stub_violation(
        messages: ["Missing comma"],
        patch_position: 4,
      )
      matching_comment1 = stub_comment(
        body: "Missing newline<br>Extra indentation",
        position: violation1.patch_position,
        original_position: violation1.patch_position,
        path: violation1.filename,
      )
      matching_comment2 = stub_comment(
        body: "Trailing whitespace detected<br>Missing comma",
        position: violation2.patch_position,
        original_position: violation2.patch_position,
        path: violation2.filename,
      )
      outdated_comment = stub_comment(
        body: "Missing comma",
        position: violation2.patch_position + 1,
        original_position: violation2.patch_position,
        path: violation2.filename,
      )
      violations = [violation1, violation2]
      comments = [matching_comment1, matching_comment2, outdated_comment]
      commenting_policy = CommentingPolicy.new(comments)

      result = commenting_policy.outdated_comments(violations)

      expect(result).to eq [outdated_comment]
    end
  end

  def stub_comment(options = {})
    defaults = { user: double("GitHubUser", type: "Bot") }
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
