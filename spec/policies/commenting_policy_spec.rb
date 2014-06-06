require 'fast_spec_helper'
require 'app/policies/commenting_policy'

describe CommentingPolicy do
  describe '#comment_permitted?' do
    context 'when violation has not previously been reported' do
      context 'when pull request has been opened' do
        it 'returns true' do
          pull_request = stubbed_pull_request(
            opened?: true,
            head_includes?: false
          )
          line_violation = stubbed_line_violation
          previous_comments_for_line = []
          commenting_policy = CommentingPolicy.new

          result = commenting_policy.comment_permitted?(
            pull_request,
            previous_comments_for_line,
            line_violation
          )

          expect(result).to be_true
        end
      end

      context 'when pull request head includes the given line' do
        it 'returns true' do
          pull_request = stubbed_pull_request
          line_violation = stubbed_line_violation
          previous_comments_for_line = []
          commenting_policy = CommentingPolicy.new

          result = commenting_policy.comment_permitted?(
            pull_request,
            previous_comments_for_line,
            line_violation
          )

          expect(result).to be_true
        end
      end
    end

    context 'when a comment reporting the violation has already been made' do
      it 'returns false' do
        message = 'Trailing whitespace'
        line_violation = stubbed_line_violation([message])
        pull_request = stubbed_pull_request
        previous_comments_on_line = [message]
        commenting_policy = CommentingPolicy.new

        result = commenting_policy.comment_permitted?(
          pull_request,
          previous_comments_on_line,
          line_violation
        )

        expect(result).to be_false
      end
    end
  end

  def stubbed_line_violation(messages = [])
    double(
      :line_violation,
      line: double(:line),
      messages: messages
    )
  end

  def stubbed_pull_request(options = { opened?: false, head_includes?: true })
    double(
      :pull_request,
      opened?: options[:opened?],
      head_includes?: options[:head_includes?],
    )
  end
end
