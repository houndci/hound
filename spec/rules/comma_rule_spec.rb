require 'fast_spec_helper'
require 'app/rules/rule'
require 'app/rules/comma_rule'

describe CommaRule, '#violated?' do
  context 'when comman has a space after' do
    it 'returns false' do
      code = ', '

      expect(code).not_to violate(CommaRule)
    end
  end

  context 'when comman does not have a space after' do
    it 'returns true' do
      code = ','

      expect(code).to violate(CommaRule)
    end
  end
end
