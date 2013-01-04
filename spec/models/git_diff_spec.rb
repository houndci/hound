require 'fast_spec_helper'
require 'app/models/git_diff'

describe GitDiff, '#additions' do
  it 'returns all of the lines that were added in a diff' do
    diff = GitDiff.new(example_diff)

    expect(diff.additions).to eq ['+ line 2', 'line 2+2']
  end

  it 'parses an actual github diff file' do
    diff_path = File.expand_path('../../support/fixtures/sample.diff', __FILE__)
    diff = GitDiff.new(File.read(diff_path))

    expect(diff.additions).to have(165).items
  end

  private

  def example_diff
    @diff ||= <<-TEXT
+++filename
   line 1
++ line 2
   line 3+3
-  line 4
+  line 2+2  
    TEXT
  end
end
