require "attr_extras"
require "rails_helper"
require "app/policies/commenting_policy"

describe CommentingPolicy do
  describe "#comment_on?" do
    context "when line with violation has not been previously commented on" do
      it "returns true" do
        pull_request = stub_pull_request
        commenting_policy = CommentingPolicy.new(pull_request)

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
          pull_request = stub_pull_request(comments: [comment])
          commenting_policy = CommentingPolicy.new(pull_request)

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
          pull_request = stub_pull_request(comments: [comment])
          commenting_policy = CommentingPolicy.new(pull_request)

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
          pull_request = stub_pull_request(comments: [comment])
          commenting_policy = CommentingPolicy.new(pull_request)

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
          pull_request = stub_pull_request(comments: [comment])
          commenting_policy = CommentingPolicy.new(pull_request)

          result = commenting_policy.comment_on?(violation)

          expect(result).to eq false
        end
      end
    end
  end

  describe "#comment_matches_any_violation?" do
    context "when messages match" do
      context "when commented on the same line, same message, by our user" do
        it "returns true" do
          violation = stub_violation(messages: ["foo bar"])
          comment = stub_comment(
            body: "foo bar<br>baz qux",
            position: violation.patch_position,
            path: violation.filename,
          )
          pull_request = stub_pull_request(comments: [comment])
          commenting_policy = CommentingPolicy.new(pull_request)

          result = commenting_policy.
            comment_matches_any_violation?(comment, [violation])

          expect(result).to eq true
        end
      end

      context "when commented by a different user" do
        it "returns false" do
          violation = stub_violation(messages: ["foo bar"])
          comment = stub_comment(
            body: "foo bar<br>baz qux",
            position: violation.patch_position,
            path: violation.filename,
            user: double(login: "bob"),
          )
          pull_request = stub_pull_request(comments: [comment])
          commenting_policy = CommentingPolicy.new(pull_request)

          result = commenting_policy.
            comment_matches_any_violation?(comment, [violation])

          expect(result).to eq false
        end
      end

      context "when commented on a different line" do
        it "returns false" do
          violation = stub_violation(messages: ["foo bar"])
          comment = stub_comment(
            body: "foo bar<br>baz qux",
            position: violation.patch_position + 1,
            path: violation.filename,
          )
          pull_request = stub_pull_request(comments: [comment])
          commenting_policy = CommentingPolicy.new(pull_request)

          result = commenting_policy.
            comment_matches_any_violation?(comment, [violation])

          expect(result).to eq false
        end
      end

      context "when commented on a different file" do
        it "returns false" do
          violation = stub_violation(messages: ["foo bar"])
          comment = stub_comment(
            body: "foo bar<br>baz qux",
            position: violation.patch_position,
            path: "some_thing_different.rb",
          )
          pull_request = stub_pull_request(comments: [comment])
          commenting_policy = CommentingPolicy.new(pull_request)

          result = commenting_policy.
            comment_matches_any_violation?(comment, [violation])

          expect(result).to eq false
        end
      end
    end

    context "when messages don't match" do
      it "returns false" do
        violation = stub_violation(messages: ["foo bar"])
        comment = stub_comment(
          body: "cool bar",
          position: violation.patch_position,
          path: violation.filename,
        )
        pull_request = stub_pull_request(comments: [comment])
        commenting_policy = CommentingPolicy.new(pull_request)

        result = commenting_policy.
          comment_matches_any_violation?(comment, [violation])

        expect(result).to eq false
      end
    end
  end

  def stub_comment(options = {})
    defaults = {
      user: double(login: Hound::GITHUB_USERNAME),
    }
    double(:github_comment, defaults.merge(options))
  end

  def stub_violation(options = {})
    defaults = {
      filename: "foo.rb",
      messages: ["Extra newline"],
      patch_position: 1,
    }
    double(:violation, defaults.merge(options))
  end

  def stub_pull_request(options = {})
    defaults = { opened?: true, comments: [] }
    double(:pull_request, defaults.merge(options))
  end
end
