require 'fast_spec_helper'
require 'app/models/style_violation'

describe StyleViolation, '#lines' do
  context 'with invalid lines of code' do
    it 'returns lines hash' do
      violation1 = double(line: 2, message: 'Trailing whitespace')
      violation2 = double(line: 2, message: 'Bad method parens')
      style_violation = StyleViolation.new(
        'file1', ['good line', 'def my_method() '], [violation1, violation2]
      )

      expect(style_violation.lines).to eq [
        line_number: 2,
        code: 'def my_method() ',
        messages: [violation1.message, violation2.message]
      ]
    end
  end
end
