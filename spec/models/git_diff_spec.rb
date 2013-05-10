require 'fast_spec_helper'
require 'app/models/git_diff'

describe GitDiff do
  describe '#additions' do
    it 'returns the new lines' do
      diff = GitDiff.new(example_diff)

      expect(diff.additions).to eq [
        'def github_repo( github_id )', '# Just a test'
      ]
    end
  end

  def example_diff
    File.read('spec/support/fixtures/example_diff.txt')
  end
end
