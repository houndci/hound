require 'fast_spec_helper'
require 'app/models/rule'
require 'app/models/whitespace_rule'

describe WhitespaceRule, '#violated?' do
  context 'with trailing whitespace' do
    it 'returns true' do
      string_with_trailing_spaces = 'def method_name  '

      expect(string_with_trailing_spaces).to violate(WhitespaceRule)
    end
  end

  context 'without trailing whitespace' do
    it 'returns false' do
      string_without_trailing_spaces = %(hello = 'world  ')

      expect(string_without_trailing_spaces).not_to violate(WhitespaceRule)
    end
  end
end
