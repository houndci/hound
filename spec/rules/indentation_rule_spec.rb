require 'fast_spec_helper'
require 'app/rules/rule'
require 'app/rules/indentation_rule'

describe IndentationRule, '#violated?' do
  context 'with soft tab indentation and two spaces' do
    it 'returns false' do
      code = '  test = true'

      expect(code).not_to violate(IndentationRule)
    end
  end

  context 'with tab indentation' do
    it 'returns true' do
      code = "\ttest = true"

      expect(code).to violate(IndentationRule)
    end
  end
end
