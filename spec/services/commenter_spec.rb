require 'fast_spec_helper'
require 'app/services/commenter'
require 'app/models/file_violation'
require 'app/models/line_violation'
require 'app/models/line'
require 'app/policies/commenting_policy'

describe Commenter do
  describe '#comment_on_violations' do
    context 'with a violation' do
      context 'when commenting is permitted' do
        it 'comments on the violation at the correct patch position' do
          line_number = 10
          filename = 'test.rb'
          comment = double(
            :comment,
            original_position: line_number,
            path: filename
          )
          pull_request = double(
            :pull_request,
            add_comment: true,
            comments: [comment]
          )
          line = double(
            :line,
            patch_position: 2
          )
          line_violation = double(
            :line_violation,
            line: line,
            line_number: line_number,
            messages: ['Trailing whitespace']
          )
          file_violation = double(
            :file_violation,
            filename: filename,
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

      context 'with no violations' do
        it 'does not comment' do
          pull_request = double(:pull_request).as_null_object
          commenter = Commenter.new

          commenter.comment_on_violations([], pull_request)

          expect(pull_request).not_to have_received(:add_comment)
        end
      end
    end

    context 'when comment is permitted' do
      it 'comments on the violations at the correct patch position' do
        line_number = 10
        filename = 'test.rb'
        comment_body = 'Trailing whitespace'
        comment = double(
          :comment,
          original_position: line_number,
          path: filename
        )
        pull_request = double(
          :pull_request,
          synchronize?: true,
          opened?: false,
          add_comment: true,
          head_includes?: true,
          comments: [comment]
        )
        line = double(
          :line,
          patch_position: 2
        )
        line_violation = double(
          :line_violation,
          line: line,
          line_number: line_number,
          messages: [comment_body]
        )
        file_violation = double(
          :file_violation,
          filename: filename,
          line_violations: [line_violation]
        )
        commenting_policy = double(:commenting_policy, comment_permitted?: true)
        allow(CommentingPolicy).to receive(:new).and_return(commenting_policy)
        commenter = Commenter.new

        commenter.comment_on_violations([file_violation], pull_request)

        expect(pull_request).to have_received(:add_comment).with(
          file_violation.filename,
          line.patch_position,
          line_violation.messages.first
        )
      end
    end

    context 'when comment is not permitted' do
      it 'does not comment' do
        line_number = 10
        filename = 'test.rb'
        comment_body = 'Trailing whitespace'
        comment = double(
          :comment,
          original_position: line_number,
          path: filename
        )
        pull_request = double(
          :pull_request,
          synchronize?: true,
          opened?: false,
          add_comment: true,
          head_includes?: true,
          comments: [comment]
        )
        line = double(
          :line,
          patch_position: 2
        )
        line_violation = double(
          :line_violation,
          line: line,
          line_number: line_number,
          messages: [comment_body]
        )
        file_violation = double(
          :file_violation,
          filename: filename,
          line_violations: [line_violation]
        )
        commenting_policy = double(
          :commenting_policy,
          comment_permitted?: false
        )
        allow(CommentingPolicy).to receive(:new).and_return(commenting_policy)
        commenter = Commenter.new

        commenter.comment_on_violations([file_violation], pull_request)

        expect(pull_request).not_to have_received(:add_comment)
      end
    end
  end
end
