require 'fast_spec_helper'
require 'app/rules/rule'
require 'app/rules/bracket_rule'

describe BracketRule, '#violated?' do
  context 'with proper syntax' do
    it 'is not violated' do
      example = 'test = [:a, 23]'

      expect(example).not_to violate(BracketRule)
    end
  end

  context 'with whitespace after bracket' do
    it 'is violated' do
      example = 'test = [ :a, 23]'

      expect(example).to violate(BracketRule)
    end
  end

  context 'with whitespace before closing bracket' do
    it 'is violated' do
      example = 'test = [:a, 23 ]'

      expect(example).to violate(BracketRule)
    end
  end

  context 'with illegal whitespace around nested brackets' do
    it 'is violated' do
      example = 'test = [[ 1, 2, 3 ], :a, 23]'

      expect(example).to violate(BracketRule)
    end
  end

  context 'with line of ruby that has no brackets' do
    it 'is not violated' do
      example = 'result = users.my_method(blah, 2) do |key, value|'

      expect(example).not_to violate(BracketRule)
    end
  end
end
