require 'rubocop'
require 'fast_spec_helper'
require 'app/models/style_checker'

describe StyleChecker, '#violations' do
  context 'when some files have violations' do
    it 'returns only the files with violations' do
      file1 = file_stub("def hi \n\tactive = true ")
      file2 = file_stub("def hello\nend\n")
      file3 = file_stub("class User  \nend\n")

      style_checker = StyleChecker.new([file1, file2, file3])
      violations = style_checker.violations

      expect(violations).to have(2).items
      expect(violations[0]).to have(2).line_violations
      expect(violations[0].line_violations[0]).to have(3).messages
      expect(violations[1]).to have(1).line_violations
    end
  end

  context 'when double quotes are used incorrectly' do
    it 'finds violations' do
      file = file_stub(<<-FILE)
def blahh
  "blahh"
end
      FILE
      style_checker = StyleChecker.new([file])

      violations = style_checker.violations

      expect(violations).not_to be_empty
    end
  end

  def file_stub(contents)
    double(
      filename: 'test_pr_file',
      source: Rubocop::SourceParser.parse(contents),
      line: '',
      relevant_line?: true
    )
  end
end
