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

  describe "#delete_comment?" do
    context "when commented by Hound's user" do
      context "and messages match" do
        context "and on the same line" do
          it "returns false" do
            violation = stub_violation(messages: ["foo bar"])
            comment = stub_comment(
              body: "foo bar<br>baz qux",
              position: violation.patch_position,
              path: violation.filename,
            )
            pull_request = stub_pull_request(comments: [comment])
            commenting_policy = CommentingPolicy.new(pull_request)

            result = commenting_policy.delete_comment?(comment, [violation])

            expect(result).to eq false
          end
        end

        context "but on a different line" do
          it "returns true" do
            violation = stub_violation(messages: ["foo bar"])
            comment = stub_comment(
              body: "foo bar<br>baz qux",
              position: violation.patch_position + 1,
              path: violation.filename,
            )
            pull_request = stub_pull_request(comments: [comment])
            commenting_policy = CommentingPolicy.new(pull_request)

            result = commenting_policy.delete_comment?(comment, [violation])

            expect(result).to eq true
          end
        end

        context "but in a different file" do
          it "returns true" do
            violation = stub_violation(messages: ["foo bar"])
            comment = stub_comment(
              body: "foo bar<br>baz qux",
              position: violation.patch_position,
              path: "some_thing_different.rb",
            )
            pull_request = stub_pull_request(comments: [comment])
            commenting_policy = CommentingPolicy.new(pull_request)

            result = commenting_policy.delete_comment?(comment, [violation])

            expect(result).to eq true
          end
        end
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

        result = commenting_policy.delete_comment?(comment, [violation])

        expect(result).to eq false
      end
    end

    context "when messages do not match" do
      it "returns true" do
        violation = stub_violation(messages: ["foo bar"])
        comment = stub_comment(
          body: "cool bar",
          position: violation.patch_position,
          path: violation.filename,
        )
        pull_request = stub_pull_request(comments: [comment])
        commenting_policy = CommentingPolicy.new(pull_request)

        result = commenting_policy.delete_comment?(comment, [violation])

        expect(result).to eq true
      end
    end
  end

  def stub_comment(options = {})
    defaults = {
      user: double("GithubUser", login: Hound::GITHUB_USERNAME),
    }
    double("GithubComment", defaults.merge(options))
  end

  def stub_violation(options = {})
    defaults = {
      filename: "foo.rb",
      messages: ["Extra newline"],
      patch_position: 1,
    }
    instance_double("Violation", defaults.merge(options))
  end

  def stub_pull_request(options = {})
    defaults = { opened?: true, comments: [] }
    instance_double("PullRequest", defaults.merge(options))
  end
end
