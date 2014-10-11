require "attr_extras"
require "fast_spec_helper"
require "app/policies/commit_commenting_policy"

describe CommitCommentingPolicy do
  describe "#allowed_for?" do
    context "when commit with violation has not been previously commented on" do
      it "returns true" do
        commit = stub_commit
        commit_commenting_policy = CommitCommentingPolicy.new(commit)

        expect(commit_commenting_policy).to be_allowed_for("Subject too long.")
      end
    end

    context "when commit with violation has been previously commented on" do
      context "when comment includes violation message" do
        it "returns false" do
          violation = "Subject too long."
          comment = stub_comment(
            body: "Subject too long.<br>Body too long."
          )
          commit = stub_commit(comments: [comment])
          commit_commenting_policy = CommitCommentingPolicy.new(commit)

          expect(commit_commenting_policy).not_to be_allowed_for(violation)
        end
      end

      context "when comment does not include violation message" do
        it "returns true" do
          violation = "Subject too long."
          comment = stub_comment(
            body: "Body too long."
          )
          commit = stub_commit(comments: [comment])
          commit_commenting_policy = CommitCommentingPolicy.new(commit)

          expect(commit_commenting_policy).to be_allowed_for(violation)
        end
      end
    end
  end

  def stub_comment(options = {})
    double(:comment, options)
  end

  def stub_commit(options = {})
    defaults = { comments: [] }
    double(:commit, defaults.merge(options))
  end
end
