require "attr_extras"
require "fast_spec_helper"
require "app/policies/commenting_policy"

describe CommentingPolicy do
  describe "#allowed_for?" do
    context "when line with violation has not been previously commented on" do
      it "returns true" do
        pull_request = stub_pull_request
        commenting_policy = CommentingPolicy.new(pull_request)

        expect(commenting_policy).to be_allowed_for(stub_violation)
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
            original_position: violation.line.patch_position,
            path: violation.filename,
            body: "Trailing whitespace detected<br>Extra newline",
          )
          pull_request = stub_pull_request(comments: [comment])
          commenting_policy = CommentingPolicy.new(pull_request)

          expect(commenting_policy).not_to be_allowed_for(violation)
        end
      end

      context "when comment exists for the same line but different files" do
        it "returns true" do
          violation = stub_violation(
            filename: "foo.rb",
            messages: ["Trailing whitespace detected"],
          )
          comment = stub_comment(
            original_position: violation.line.patch_position,
            path: "bar.rb",
          )
          pull_request = stub_pull_request(comments: [comment])
          commenting_policy = CommentingPolicy.new(pull_request)

          expect(commenting_policy).to be_allowed_for(violation)
        end
      end

      context "when comment does not include violation message" do
        it "returns true" do
          violation = stub_violation(
            filename: "foo.rb",
            messages: ["Trailing whitespace detected"],
          )
          comment = stub_comment(
            original_position: violation.line.patch_position,
            path: violation.filename,
            body: "Extra newline",
          )
          pull_request = stub_pull_request(comments: [comment])
          commenting_policy = CommentingPolicy.new(pull_request)

          expect(commenting_policy).to be_allowed_for(violation)
        end
      end
    end
  end

  def stub_comment(options = {})
    double(:comment, options)
  end

  def stub_violation(options = {})
    line = double(:line, patch_position: 1)
    defaults = { filename: "foo.rb", messages: ["Extra newline"], line: line }
    double(:violation, defaults.merge(options))
  end

  def stub_pull_request(options = {})
    defaults = { opened?: true, comments: [] }
    double(:pull_request, defaults.merge(options))
  end
end
