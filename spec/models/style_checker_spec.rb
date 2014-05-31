require 'rubocop'
require 'fast_spec_helper'
require 'app/models/ruby_style_guide'
require 'app/models/coffee_script_style_guide'
require 'app/models/style_checker'
require 'app/models/file_violation'
require 'app/models/line_violation'

describe StyleChecker, '#violations' do
  it 'returns a collection of files with style violations' do
    modified_file1 = stub_modified_file("good.rb", "def good; end", "Ruby")
    modified_file2 = stub_modified_file(
      "bad.rb", "def bad( a ); a; end  ", "Ruby"
    )
    modified_file3 = stub_modified_file("good.coffee", "a = 7", "CoffeeScript")
    modified_file4 = stub_modified_file("bad.coffee", "1" * 81, "CoffeeScript")
    expected_line_violation1 = LineViolation.new(
      modified_file2.modified_line_at,
      ['Space inside parentheses detected.', 'Trailing whitespace detected.']
    )
    expected_line_violation2 = LineViolation.new(
      modified_file4.modified_line_at,
      ['Line exceeds maximum allowed length']
    )
    config = "Style/EndOfLine:\n  Enabled: false"

    style_checker = StyleChecker.new(
      [modified_file1, modified_file2, modified_file3, modified_file4 ],
      config
    )

    expect(style_checker.violations).to eq [
      FileViolation.new(modified_file2.filename, [expected_line_violation1]),
      FileViolation.new(modified_file4.filename, [expected_line_violation2])
    ]
  end

  private

  def stub_modified_file(filename, contents, language)
    formatted_contents = "#{contents}\n"
    double(
      :modified_file,
      filename: filename,
      contents: formatted_contents,
      ruby?: language == "Ruby",
      coffeescript?: language == "CoffeeScript",
      language: language,
      removed?: false,
      relevant_line?: true,
      modified_line_at: 1
    )
  end
end
