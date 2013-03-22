require 'fast_spec_helper'
require 'app/models/git_diff'

describe GitDiff, '#additions' do
  it 'returns all of the lines that were added in a diff' do
    diff_url = 'http://example.com/1.diff'
    stub_diff_request(diff_url, example_diff)
    diff = GitDiff.new(diff_url)

    expect(diff.additions).to eq ['+ line 2', 'line 2+2']
  end

  it 'parses an actual github diff file' do
    diff_url = 'http://example.com/1.diff'
    stub_diff_request(diff_url, real_diff)
    diff = GitDiff.new(diff_url)

    expect(diff).to have(165).additions
  end

  private

  def stub_diff_request(diff_url, diff_content)
    stub_request(:get, diff_url).
      to_return(:status => 200, :body => diff_content, :headers => {})
  end

  def example_diff
    <<-TEXT
+++filename
   line 1
++ line 2
   line 3+3
-  line 4
+  line 2+2
    TEXT
  end

  def real_diff
    File.read('spec/support/fixtures/sample.diff')
  end
end
