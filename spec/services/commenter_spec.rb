require 'fast_spec_helper'
require 'app/services/commenter'
require 'app/policies/commenting_policy'

describe Commenter do
  describe '#comment_on_violations' do
    context "when comment is allowed" do
      context "with a violation" do
        it "comments on the violation" do
          pull_request = double(:pull_request, comment_on_violation: nil)
          violation = double(:violation)
          commenter = Commenter.new(pull_request)
          policy = double(:commenting_policy, allowed_for?: true)
          allow(CommentingPolicy).to receive(:new).and_return(policy)

          commenter.comment_on_violations([violation])

          expect(pull_request).to have_received(:comment_on_violation).
            with(violation)
        end
      end

      context 'with no violations' do
        it 'does not comment' do
          pull_request = double(:pull_request).as_null_object
          commenter = Commenter.new(pull_request)

          commenter.comment_on_violations([])

          expect(pull_request).not_to have_received(:comment_on_violation)
        end
      end
    end

    context "when comment is not allowed" do
      it "does not add comment" do
        pull_request = double(:pull_request).as_null_object
        commenter = Commenter.new(pull_request)
        policy = double(:commenting_policy, allowed_for?: false)
        allow(CommentingPolicy).to receive(:new).and_return(policy)

        commenter.comment_on_violations([double(:violation)])

        expect(pull_request).not_to have_received(:comment_on_violation)
      end
    end
  end
end
