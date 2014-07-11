require 'rubocop'
require 'fast_spec_helper'
require 'app/models/style_guide'
require 'app/models/style_checker'
require 'app/models/file_violation'
require 'app/models/line_violation'

describe StyleChecker, '#violations' do
  it 'returns a collection of files with style violations' do
    modified_file1 = stub_modified_file("good.rb", "def good; end")
    modified_file2 = stub_modified_file("bad.rb", "def bad( a ); a; end  ")
    expected_line_violation = LineViolation.new(
      modified_file2.modified_line_at,
      ['Space inside parentheses detected.', 'Trailing whitespace detected.']
    )

    style_checker = StyleChecker.new([modified_file1, modified_file2])

    expect(style_checker.violations).to eq [
      FileViolation.new(modified_file2.filename, [expected_line_violation])
    ]
  end

  private

  def stub_modified_file(filename, contents)
    formatted_contents = "#{contents}\n"
    double(
      :modified_file,
      filename: filename,
      contents: formatted_contents,
      ruby?: true,
      removed?: false,
      relevant_line?: true,
      modified_line_at: 1
    )
  end
end
