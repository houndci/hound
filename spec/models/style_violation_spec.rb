require 'fast_spec_helper'
require 'app/models/style_violation'

describe StyleViolation, '#lines' do
  context 'with invalid lines of code' do
    it 'returns lines hash' do
      violation = double(line: 2, message: 'Trailing space!')
      style_violation = StyleViolation.new(
        'file1',
        ['good line', 'bad line ', 'ignored bad line '],
        [1, 2],
        [violation]
      )

      expect(style_violation.lines).to eq [
        line_number: 2, code: 'bad line ', messages: ['Trailing space!']
      ]
    end
  end
end
