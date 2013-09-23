require 'fast_spec_helper'
require 'app/rules/rule'
require 'app/rules/line_length_rule'

describe LineLengthRule, '#violated?' do
  context 'when line is shorter than 80 characters' do
    it 'returns false' do
      code = 'a'

      expect(code).not_to violate(LineLengthRule)
    end
  end

  context 'when line is longer than 80 characters' do
    it 'returns true' do
      code = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'

      expect(code).to violate(LineLengthRule)
    end
  end
end
