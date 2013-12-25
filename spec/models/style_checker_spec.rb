require 'rubocop'
require 'fast_spec_helper'
require 'app/models/style_checker'
require 'app/models/modified_file'

describe StyleChecker, '#violations' do
  context 'when some files have violations' do
    it 'returns only the files with violations' do
      file1 = ModifiedFile.new('file1', "first line \n\tactive = true ", [1, 2])
      file2 = ModifiedFile.new('file2', "def hello\nend\n", [1, 2])
      file3 = ModifiedFile.new('file3', "class User  \nend\n", [1, 2])

      style_checker = StyleChecker.new([file1, file2, file3])
      violations = style_checker.violations

      expect(violations).to have(2).items
      expect(violations[0]).to have(2).line_violations
      expect(violations[0].line_violations[0]).to have(3).messages
      expect(violations[1]).to have(1).line_violations
    end
  end
end
