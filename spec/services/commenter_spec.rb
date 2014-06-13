require 'fast_spec_helper'
require 'app/services/commenter'
require 'app/models/file_violation'
require 'app/models/line_violation'
require 'app/models/line'
require 'app/models/comment'
require 'app/policies/commenting_policy'

describe Commenter do
  describe '#comment_on_violations' do
    context 'with a violation' do
      context 'when commenting is permitted' do
        it 'comments on the violation at the correct patch position' do
          pull_request = double(
            :pull_request,
            add_comment: true,
          )
          line = double(
            :line,
            patch_position: 2
          )
          line_violation = double(
            :line_violation,
            line: line,
            messages: ['Trailing whitespace']
          )
          file_violation = double(
            :file_violation,
            filename: 'test.rb',
            line_violations: [line_violation]
          )
          policy = double(:commenting_policy, comment_permitted?: true)
          allow(CommentingPolicy).to receive(:new).and_return(policy)
          commenter = Commenter.new

          commenter.comment_on_violations([file_violation], pull_request)

          expect(pull_request).to have_received(:add_comment).with(
            file_violation.filename,
            line.patch_position,
            line_violation.messages.first
          )
        end
      end

      context 'when commenting is not permitted' do
        it 'does not comment' do
          pull_request = double(
            :pull_request,
            add_comment: true
          )
          line_violation = double(
            :line_violation,
            line: double(:line)
          )
          file_violation = double(
            :file_violation,
            line_violations: [line_violation]
          )
          policy = double(:commenting_policy, comment_permitted?: false)
          allow(CommentingPolicy).to receive(:new).and_return(policy)
          commenter = Commenter.new

          commenter.comment_on_violations([file_violation], pull_request)

          expect(pull_request).not_to have_received(:add_comment)
        end
      end
    end

    context 'with no violations' do
      it 'does not comment' do
        pull_request = double(:pull_request).as_null_object
        commenter = Commenter.new

        commenter.comment_on_violations([], pull_request)

        expect(pull_request).not_to have_received(:add_comment)
      end
    end
  end
end
