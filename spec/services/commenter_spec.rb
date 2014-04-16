require 'fast_spec_helper'
require 'app/services/commenter'
require 'app/models/file_violation'
require 'app/models/line_violation'
require 'app/models/line'
require 'app/models/pull_request'

describe Commenter do
  describe '#comment_on_violations' do
    context 'with violations' do
      context 'when pull request is opened' do
        it 'comments on the violations at the correct patch position' do
          pull_request = double(
            :pull_request,
            opened?: true,
            add_comment: true,
            head_includes?: false,
          )
          line_number = 10
          line = double(
            :line,
            line_number: line_number,
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
          commenter = Commenter.new

          commenter.comment_on_violations([file_violation], pull_request)

          expect(pull_request).to have_received(:add_comment).with(
            file_violation.filename,
            line.patch_position,
            line_violation.messages.first
          )
        end
      end

      context 'when pull request is synchronize' do
        context 'when the violation is in the last commit' do
          it 'comments on the violations at the correct patch position' do
            pull_request = double(
              :pull_request,
              synchronize?: true,
              opened?: false,
              add_comment: true,
              head_includes?: true,
              config_hash: false,
            )
            line_number = 10
            line = double(
              :line,
              line_number: line_number,
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
            commenter = Commenter.new

            commenter.comment_on_violations([file_violation], pull_request)

            expect(pull_request).to have_received(:add_comment)
          end
        end

        context 'when the violation is not in the last commit' do
          it 'does not comment' do
            pull_request = double(
              :pull_request,
              synchronize?: true,
              opened?: false,
              add_comment: true,
              head_includes?: false
            )
            line_number = 10
            line = double(
              :line,
              line_number: line_number,
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
            commenter = Commenter.new

            commenter.comment_on_violations([file_violation], pull_request)

            expect(pull_request).not_to have_received(:add_comment)
          end
        end
      end
    end

    context 'with no violations' do
      context 'with SuccessComment configuration' do
        let(:config_hash) { { 'SuccessNotification' => { 'Enabled' => true } } }

        context 'when the pull request is open' do
          it 'adds a comment to the pull request' do

            pull_request = double(
              :pull_request,
              synchronize?: true,
              add_comment: true,
              success_notification_enabled: true,
            )
            commenter = Commenter.new

            commenter.comment_on_violations([], pull_request)

            expect(pull_request).to have_received(:add_comment).with(
              nil, nil, PullRequest::SUCCESS_MESSAGE
            )
          end
        end
        context 'when the pull request is not open' do
          it 'does not comment on the pull request' do
            commenter = Commenter.new
            pull_request = double(:pull_request,
              success_notification_enabled: false,
            ).as_null_object

            commenter.comment_on_violations([], pull_request)

            expect(pull_request).not_to have_received(:add_comment)
          end
        end
      end

      context 'without SuccessComment configuration' do
        it 'does not comment' do
          commenter = Commenter.new
          pull_request = double(:pull_request,
            success_notification_enabled: false,
          ).as_null_object

          commenter.comment_on_violations([], pull_request)

          expect(pull_request).not_to have_received(:add_comment)
        end
      end
    end
  end
end
