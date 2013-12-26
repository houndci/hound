require 'rubocop'
require 'fast_spec_helper'
require 'app/models/style_checker'
require 'app/models/style_violation'

describe StyleChecker, '#violations' do
  context 'when some files have violations' do
    it 'returns only the files with violations' do
      file1 = double(filename: 'file1', contents: "first line \n\tindentation = true ", line_numbers: [1, 2])
      file2 = double(filename: 'file2', contents: "all good\n", line_numbers: [1])
      file3 = double(filename: 'file3', contents: 'trailing whitespace ', line_numbers: [1])

      style_checker = StyleChecker.new([file1, file2, file3])

      expect(style_checker).to have(2).violations
      expect(style_checker.violations[0]).to have(2).lines
      expect(style_checker.violations[1]).to have(1).lines
    end
  end
end
