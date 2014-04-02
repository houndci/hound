require 'fast_spec_helper'
require 'app/services/commenter'
require 'app/models/file_violation'
require 'app/models/line_violation'
require 'app/models/line'

describe Commenter do
  describe '#comment_on_violations' do
    context 'with violations' do
      context 'when pull request is opened' do
        it 'comments on the violations at the correct patch position' do
          commenter = Commenter.new
          filename = 'test.rb'
          line_number = 1
          content = 'one = 1 '
          patch_position = 2
          violation_message = 'Trailing whitespace'
          line_violation = LineViolation.new(
            line_number,
            content,
            [violation_message]
          )
          modified_line = Line.new(content, line_number, patch_position)
          file_violation = FileViolation.new(
            filename,
            [line_violation],
            [modified_line]
          )
          pull_request = double(:pull_request, opened?: true).as_null_object

          commenter.comment_on_violations([file_violation], pull_request)

          expect(pull_request).to have_received(:add_comment).with(
            filename,
            patch_position,
            violation_message
          )
        end
      end

      context 'when pull request is synchronized' do
        context 'when the violation is in the last commit' do
          it 'comments on the violations at the correct patch position'
        end

        context 'when the violation is not in the last commit' do
          it 'does not comment'
        end
      end
    end

    context 'with no violations' do
      it 'does not comment' do
        commenter = Commenter.new
        pull_request = double(:pull_request).as_null_object

        commenter.comment_on_violations([], pull_request)

        expect(pull_request).not_to have_received(:add_comment)
      end
    end
  end
end
