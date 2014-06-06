require 'fast_spec_helper'
require 'app/policies/commenting_policy'

describe CommentingPolicy, '#comment_permitted?' do
  context 'when pull request is opened' do
    it 'returns true' do
      pull_request = double(
        :pull_request,
        opened?: true,
        head_includes?: false,
        comments_on: []
      )
      position = 1
      line = double(:line, line_number: position)
      comment = double(
        :comment,
        line: line,
        position: 1,
        messages: [],
        violation_messages: [],
        path: 'test.rb'
      )
      commenting_policy = CommentingPolicy.new

      result = commenting_policy.comment_permitted?(pull_request, comment)

      expect(result).to be_true
    end
  end

  context 'when the given line is included in the most recent commit' do
    it 'returns true' do
      pull_request = double(
        :pull_request,
        opened?: false,
        head_includes?: true,
        comments_on: []
      )
      position = 1
      line = double(:line, line_number: position)
      comment = double(
        :comment,
        line: line,
        messages: [],
        position: position,
        violation_messages: [],
        path: 'test.rb'
      )
      commenting_policy = CommentingPolicy.new

      result = commenting_policy.comment_permitted?(pull_request, comment)

      expect(result).to be_true
    end
  end
end
