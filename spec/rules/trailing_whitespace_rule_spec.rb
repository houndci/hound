require 'fast_spec_helper'
require 'app/rules/rule'
require 'app/rules/trailing_whitespace_rule'

describe TrailingWhitespaceRule, '#violated?' do
  context 'when line does not have trailing whitespace' do
    it 'returns false' do
      code = 'a'

      expect(code).not_to violate(TrailingWhitespaceRule)
    end
  end

  context 'when line has trailing whitespace' do
    it 'returns true' do
      code = 'a '

      expect(code).to violate(TrailingWhitespaceRule)
    end
  end
end
